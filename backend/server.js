const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const admin = require('firebase-admin');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

function initializeFirebaseAdmin() {
  if (admin.apps.length > 0) {
    return;
  }

  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (serviceAccountJson) {
    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccountJson)),
    });
    return;
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

initializeFirebaseAdmin();

const db = admin.firestore();

function toDate(value) {
  if (!value) {
    return null;
  }

  if (typeof value.toDate === 'function') {
    return value.toDate();
  }

  if (value instanceof Date) {
    return value;
  }

  if (typeof value === 'string' || typeof value === 'number') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (typeof value === 'object' && typeof value._seconds === 'number') {
    return new Date(value._seconds * 1000);
  }

  return null;
}

function toTimeLabel(date) {
  if (!date) {
    return '';
  }

  return new Intl.DateTimeFormat('en-US', {
    hour: 'numeric',
    minute: '2-digit',
  }).format(date);
}

function toAppointmentLabel(date) {
  if (!date) {
    return 'No upcoming appointments';
  }

  const now = new Date();
  const startToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const startTomorrow = new Date(startToday);
  startTomorrow.setDate(startTomorrow.getDate() + 1);
  const startDayAfterTomorrow = new Date(startTomorrow);
  startDayAfterTomorrow.setDate(startDayAfterTomorrow.getDate() + 1);

  if (date >= startToday && date < startTomorrow) {
    return `Today, ${toTimeLabel(date)}`;
  }

  if (date >= startTomorrow && date < startDayAfterTomorrow) {
    return `Tomorrow, ${toTimeLabel(date)}`;
  }

  const dayMonth = new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
  }).format(date);
  return `${dayMonth}, ${toTimeLabel(date)}`;
}

function computeAdherenceSubtitle(percent) {
  if (percent >= 90) {
    return 'Excellent adherence';
  }
  if (percent >= 75) {
    return 'Good progress';
  }
  if (percent >= 50) {
    return 'Needs attention';
  }
  return 'High missed-dose risk';
}

function computeHealthScore(adherencePercent, latestSeverity) {
  const severityAdjustment = {
    mild: 2,
    moderate: 0,
    severe: -6,
    extreme: -12,
  };

  const adjustment = severityAdjustment[String(latestSeverity || '').toLowerCase()] ?? 0;
  const raw = adherencePercent + adjustment;
  return Math.min(100, Math.max(0, Math.round(raw)));
}

function deriveInsight({
  adherencePercent,
  adherenceSubtitle,
  latestSymptom,
  nextAppointmentDoctor,
  nextAppointmentDate,
}) {
  const appointmentLine = nextAppointmentDoctor && nextAppointmentDate
    ? `${nextAppointmentDoctor} is scheduled ${toAppointmentLabel(nextAppointmentDate).toLowerCase()}.`
    : 'No upcoming appointment is scheduled yet.';

  const symptomLine = latestSymptom
    ? `Latest logged symptom: ${latestSymptom}.`
    : 'No recent symptom logs found.';

  return `Adherence is at ${adherencePercent}% (${adherenceSubtitle.toLowerCase()}). ${symptomLine} ${appointmentLine}`;
}

function deriveProfileSummary(userData, recentHealthLogs) {
  const profileData = (userData.profile && typeof userData.profile === 'object')
    ? userData.profile
    : {};
  const onboardingData = (userData.onboarding && typeof userData.onboarding === 'object')
    ? userData.onboarding
    : {};

  const latestLog = recentHealthLogs[0] || null;
  const explicitHealthLogsSummary = String(profileData.healthLogsSummary || userData.healthLogsSummary || '').trim();
  const healthLogsSummary = explicitHealthLogsSummary || (latestLog
    ? `Latest log: ${latestLog.symptom || 'health update'}${latestLog.loggedAt ? ` on ${toTimeLabel(latestLog.loggedAt)}` : ''}.`
    : 'Symptoms, vitals, journals');

  return {
    uid: String(userData.uid || ''),
    name: String(userData.name || userData.displayName || 'Friend').trim() || 'Friend',
    email: String(userData.email || '').trim(),
    age: Number.isFinite(Number(userData.age)) ? Number(userData.age) : 0,
    gender: userData.gender ? String(userData.gender) : null,
    profile: {
      conditionSummary: String(profileData.conditionSummary || onboardingData.conditions || '').trim() || null,
      careTeamSummary: String(profileData.careTeamSummary || onboardingData.careTeamSummary || '').trim() || null,
      healthLogsSummary,
      avatarUrl: profileData.avatarUrl ? String(profileData.avatarUrl) : null,
      updatedAt: profileData.updatedAt || null,
    },
    onboarding: Object.keys(onboardingData).length > 0 ? onboardingData : null,
  };
}

function toProfileResponse(userSnapshot, recentHealthLogs) {
  if (!userSnapshot.exists) {
    return null;
  }

  const userData = userSnapshot.data() || {};
  return deriveProfileSummary({ ...userData, uid: userSnapshot.id }, recentHealthLogs);
}

function toMedicationItem(dose) {
  const isTaken = dose.status === 'taken' || dose.status === 'late';
  const dosageText = String(dose.dosage || '').trim();
  const timeLabel = toTimeLabel(dose.takenTime || dose.scheduledTime);

  return {
    id: String(dose.id),
    medicationId: String(dose.medicationId || ''),
    name: String(dose.medicationName || 'Medication'),
    dosage: dosageText,
    details: isTaken
      ? `${dosageText} • Taken at ${timeLabel}`
      : `${dosageText} • ${timeLabel}`,
    status: dose.status,
    isTaken,
  };
}

app.get('/health', (_req, res) => {
  res.status(200).json({ ok: true });
});

app.get('/api/profile/:uid', async (req, res) => {
  const uid = String(req.params.uid || '').trim();
  if (!uid) {
    res.status(400).json({ error: 'uid is required.' });
    return;
  }

  try {
    const userRef = db.collection('users').doc(uid);
    const [userSnapshot, healthLogsSnapshot] = await Promise.all([
      userRef.get(),
      userRef.collection('health_logs').orderBy('loggedAt', 'desc').limit(5).get(),
    ]);

    const recentHealthLogs = healthLogsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...(doc.data() || {}),
      loggedAt: toDate((doc.data() || {}).loggedAt),
      symptom: String((doc.data() || {}).symptom || ''),
    }));

    const profile = toProfileResponse(userSnapshot, recentHealthLogs);
    if (!profile) {
      res.status(404).json({ error: 'Profile not found.' });
      return;
    }

    res.status(200).json(profile);
  } catch (error) {
    console.error('Failed to build profile payload:', error);
    res.status(500).json({
      error: 'Failed to fetch profile data.',
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

app.get('/api/home/:uid', async (req, res) => {
  const uid = String(req.params.uid || '').trim();
  if (!uid) {
    res.status(400).json({ error: 'uid is required.' });
    return;
  }

  try {
    const userRef = db.collection('users').doc(uid);
    const [
      userSnapshot,
      medicationsSnapshot,
      dosesSnapshot,
      appointmentsSnapshot,
      unreadNotificationsSnapshot,
      healthLogsSnapshot,
    ] = await Promise.all([
      userRef.get(),
      userRef.collection('medications').where('isActive', '==', true).limit(20).get(),
      userRef.collection('medication_doses').orderBy('createdAt', 'desc').limit(200).get(),
      userRef.collection('appointments').orderBy('appointmentDateTime', 'asc').limit(20).get(),
      userRef.collection('medication_notifications').where('isRead', '==', false).limit(1).get(),
      userRef.collection('health_logs').orderBy('loggedAt', 'desc').limit(5).get(),
    ]);

    const userData = userSnapshot.exists ? (userSnapshot.data() || {}) : {};
    const userName = String(userData.name || userData.displayName || 'Friend').trim() || 'Friend';
    const userInitials = userName
      .split(/\s+/)
      .filter(Boolean)
      .slice(0, 2)
      .map((part) => part[0].toUpperCase())
      .join('') || 'DD';

    const now = new Date();
    const startToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endToday = new Date(startToday);
    endToday.setDate(endToday.getDate() + 1);

    const allDoses = dosesSnapshot.docs
      .map((doc) => ({ id: doc.id, ...(doc.data() || {}) }))
      .map((dose) => ({
        ...dose,
        scheduledTime: toDate(dose.scheduledTime),
        takenTime: toDate(dose.takenTime),
        status: String(dose.status || 'pending').toLowerCase(),
      }));

    const todaysDoses = allDoses
      .filter((dose) => dose.scheduledTime && dose.scheduledTime >= startToday && dose.scheduledTime < endToday)
      .sort((left, right) => left.scheduledTime - right.scheduledTime);

    const takenCount = todaysDoses.filter((dose) => dose.status === 'taken' || dose.status === 'late').length;
    const adherencePercent = todaysDoses.length > 0
      ? Math.round((takenCount / todaysDoses.length) * 100)
      : 0;
    const adherenceSubtitle = computeAdherenceSubtitle(adherencePercent);

    const healthLogs = healthLogsSnapshot.docs
      .map((doc) => ({ id: doc.id, ...(doc.data() || {}) }))
      .map((log) => ({
        ...log,
        loggedAt: toDate(log.loggedAt),
        severity: String(log.severity || 'Moderate'),
        symptom: String(log.symptom || ''),
      }))
      .sort((a, b) => {
        const left = a.loggedAt ? a.loggedAt.getTime() : 0;
        const right = b.loggedAt ? b.loggedAt.getTime() : 0;
        return right - left;
      });

    const latestHealthLog = healthLogs[0] || null;
    const healthScore = computeHealthScore(adherencePercent, latestHealthLog?.severity);

    const upcomingAppointment = appointmentsSnapshot.docs
      .map((doc) => ({ id: doc.id, ...(doc.data() || {}) }))
      .map((appointment) => ({
        ...appointment,
        appointmentDateTime: toDate(appointment.appointmentDateTime),
        status: String(appointment.status || 'upcoming').toLowerCase(),
      }))
      .find((appointment) => {
        if (!appointment.appointmentDateTime) {
          return false;
        }
        if (appointment.status === 'completed' || appointment.status === 'cancelled') {
          return false;
        }
        return appointment.appointmentDateTime >= now;
      }) || null;

    const medicationTiles = todaysDoses.slice(0, 4).map(toMedicationItem);

    if (medicationTiles.length === 0) {
      for (const doc of medicationsSnapshot.docs.slice(0, 2)) {
        const medication = doc.data() || {};
        medicationTiles.push({
          id: doc.id,
          medicationId: doc.id,
          name: String(medication.name || 'Medication'),
          dosage: String(medication.dosage || ''),
          details: `${String(medication.dosage || '')} • No dose scheduled today`,
          status: 'pending',
          isTaken: false,
        });
      }
    }

    const insight = deriveInsight({
      adherencePercent,
      adherenceSubtitle,
      latestSymptom: latestHealthLog?.symptom || '',
      nextAppointmentDoctor: upcomingAppointment?.doctorName || '',
      nextAppointmentDate: upcomingAppointment?.appointmentDateTime || null,
    });

    res.status(200).json({
      user: {
        id: uid,
        name: userName,
        initials: userInitials,
      },
      quickStats: {
        healthScore,
        adherencePercent,
        adherenceSubtitle,
        nextAppointment: {
          id: upcomingAppointment?.id || null,
          doctorName: upcomingAppointment?.doctorName || 'No upcoming visit',
          dateTime: upcomingAppointment?.appointmentDateTime
            ? upcomingAppointment.appointmentDateTime.toISOString()
            : null,
          label: toAppointmentLabel(upcomingAppointment?.appointmentDateTime || null),
        },
      },
      aiInsight: insight,
      notifications: {
        hasUnread: !unreadNotificationsSnapshot.empty,
      },
      medications: medicationTiles,
      generatedAt: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Failed to build home payload:', error);
    res.status(500).json({
      error: 'Failed to fetch home data.',
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

const port = Number(process.env.PORT || 8080);
app.listen(port, () => {
  console.log(`DailyDose backend running on port ${port}`);
});
