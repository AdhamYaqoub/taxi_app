// bot.js
require('dotenv').config();
const { Telegraf, session, Markup } = require('telegraf');
const axios = require('axios');
const fs = require('fs').promises; // لإدارة ملف .json للمستخدمين المرتبطين

// تأكد من وجود المتغيرات البيئية
if (!process.env.BOT_TOKEN || !process.env.API_BASE_URL) {
  console.error('Environment variables BOT_TOKEN or API_BASE_URL are missing. Please check your .env file or Render environment settings.');
  process.exit(1);
}

const bot = new Telegraf(process.env.BOT_TOKEN);
bot.use(session());

const initState = {
  stage: 'start',
  email: '',
  password: '',
  token: '',
  userId: '',
  pickup: '',
  destination: '',
  pickupLocation: null,
  destinationLocation: null,
  datetime: ''
};

// --- إدارة المستخدمين المرتبطين (Permanent Linked Users) ---
let linkedUsers = {}; 
const LINKED_USERS_FILE = 'linked_users.json';

// **تعديل بسيط هنا لزيادة الموثوقية على Render**
async function loadLinkedUsers() {
  try {
    const data = await fs.readFile(LINKED_USERS_FILE, 'utf8');
    linkedUsers = JSON.parse(data);
    console.log(`Loaded ${Object.keys(linkedUsers).length} linked users from file.`);
  } catch (error) {
    if (error.code === 'ENOENT') {
      // الملف غير موجود، وهذا متوقع في أول تشغيل أو بعد إعادة تشغيل على Render
      console.log('linked_users.json not found, starting with an empty user list.');
      linkedUsers = {};
    } else {
      // لأي خطأ آخر، قم بتسجيله ولكن لا توقف البوت
      console.error('Error loading linked users from file, starting with an empty list:', error);
      linkedUsers = {};
    }
  }
}

async function saveLinkedUsers() {
  try {
    // نستخدم مسارًا قابلاً للكتابة في Render. `/tmp` هو خيار شائع لكنه مؤقت أيضًا.
    // كتابة الملف في الجذر الرئيسي قد يعمل في بعض الحالات.
    await fs.writeFile(LINKED_USERS_FILE, JSON.stringify(linkedUsers, null, 2), 'utf8');
    console.log('Linked users saved to file.');
  } catch (error) {
    console.error('Error saving linked users to file:', error);
    // هذا الخطأ حرج لأنه يعني أن البيانات لن يتم حفظها.
  }
}

// تحميل المستخدمين عند بدء البوت
loadLinkedUsers();


// --- بقية الكود تبقى كما هي تمامًا ---

bot.start(async (ctx) => {
  ctx.session = { ...initState }; 
  const telegramUserId = ctx.from.id;
  const user = linkedUsers[telegramUserId];

  if (user) {
    ctx.session.token = user.appToken;
    ctx.session.userId = user.appUserId;
    ctx.session.stage = 'ready_for_booking';
    const fullName = user.fullName || user.appUserId;
    return ctx.reply(
      `مرحباً ${fullName}! حسابك مرتبط بالفعل.\nالرجاء إدخال أمر لحجز رحلة جديدة /book_trip أو /my_bookings لعرض رحلاتك.`, 
      Markup.keyboard([
        ['حجز رحلة جديدة', 'رحلاتي']
      ]).resize().oneTime()
    );
  } else {
    ctx.session.stage = 'awaiting_email';
    return ctx.reply('مرحبًا بك في TaxiGo 🚖\nيرجى إدخال بريدك الإلكتروني:');
  }
});

bot.command('cancel', (ctx) => {
  ctx.session = { ...initState };
  return ctx.reply('❌ تم إلغاء العملية. يمكنك بدء محادثة جديدة بكتابة /start');
});

bot.command('book_trip', async (ctx) => {
  if (!ctx.session) ctx.session = { ...initState };
  const telegramUserId = ctx.from.id;
  const user = linkedUsers[telegramUserId];
  if (!user) {
    ctx.session.stage = 'awaiting_email'; 
    return ctx.reply('يجب عليك تسجيل الدخول أولاً قبل حجز رحلة. يرجى إدخال بريدك الإلكتروني:');
  }
  ctx.session = { ...initState, token: user.appToken, userId: user.appUserId }; 
  ctx.session.stage = 'awaiting_pickup_location';
  return ctx.reply('📍 الرجاء إرسال موقعك الحالي:', Markup.keyboard([
    Markup.button.locationRequest('📍 مشاركة الموقع')
  ]).oneTime().resize());
});

bot.command('my_bookings', async (ctx) => {
  const telegramUserId = ctx.from.id;
  const user = linkedUsers[telegramUserId];
  if (!user) {
    return ctx.reply('يجب عليك تسجيل الدخول وربط حسابك أولاً لعرض رحلاتك. استخدم أمر /start.');
  }
  await ctx.reply(`جاري جلب رحلاتك يا ${user.fullName || user.appUserId}.`);
  ctx.reply('جلب الرحلات قيد التطوير!');
});

async function reverseGeocode(lat, lon) {
  const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&zoom=18&addressdetails=1`;
  try {
    const res = await axios.get(url, { headers: { 'User-Agent': 'TaxiGoBot/1.0' } });
    if (res.data && res.data.address) {
      const address = res.data.address;
      return [address.road, address.suburb, address.city, address.country].filter(Boolean).join(', ');
    }
  } catch (error) { console.error('Reverse geocoding error:', error.message); }
  return null;
}

async function geocodeLocationByName(name) {
  const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(name + ', فلسطين')}&limit=1`;
  try {
    const res = await axios.get(url, { headers: { 'User-Agent': 'TaxiGoBot/1.0' } });
    if (res.data.length > 0) {
      const result = res.data[0];
      return { latitude: parseFloat(result.lat), longitude: parseFloat(result.lon), displayName: result.display_name };
    }
  } catch (error) { console.error('Geocoding error:', error.message); }
  throw new Error('❌ لم يتم العثور على الموقع');
}

bot.on('location', async (ctx) => {
  if (!ctx.session) ctx.session = { ...initState };
  const stage = ctx.session.stage;
  const loc = ctx.message.location;

  if (stage === 'awaiting_pickup_location') {
    ctx.session.pickupLocation = { latitude: loc.latitude, longitude: loc.longitude };
    try {
      const locationName = await reverseGeocode(loc.latitude, loc.longitude);
      ctx.session.pickup = locationName || `إحداثيات: ${loc.latitude.toFixed(4)}, ${loc.longitude.toFixed(4)}`;
      ctx.session.stage = 'awaiting_destination_text';
      return ctx.reply(`📍 تم تحديد موقع الانطلاق: ${ctx.session.pickup}\n\n🚩 الرجاء إدخال الوجهة (مثال: نابلس):`);
    } catch (error) {
      console.error('Error during pickup location reverse geocoding:', error);
      ctx.session.pickup = `إحداثيات: ${loc.latitude.toFixed(4)}, ${loc.longitude.toFixed(4)}`;
      ctx.session.stage = 'awaiting_destination_text';
      return ctx.reply('📍 تم تحديد موقعك الحالي (من خلال الإحداثيات).\n🚩 الرجاء إدخال الوجهة (مثال: نابلس):');
    }
  } else {
    return ctx.reply('تلقيت موقعاً ولكنني لا أنتظر تحديد موقع حالياً. يرجى البدء من جديد باستخدام /start أو /book_trip.');
  }
});

bot.on('text', async (ctx) => {
  if (!ctx.session) ctx.session = { ...initState };
  const stage = ctx.session.stage || 'start';
  const msg = ctx.message.text.trim();

  if (linkedUsers[ctx.from.id]) {
      const user = linkedUsers[ctx.from.id];
      if (msg === 'حجز رحلة جديدة') {
          await ctx.reply(`تمام ${user.fullName || user.appUserId}! يرجى كتابة الأمر /book_trip لبدء حجز جديد.`);
          return;
      } else if (msg === 'رحلاتي') {
          await ctx.reply(`جاري جلب رحلاتك يا ${user.fullName || user.appUserId}. يرجى كتابة الأمر /my_bookings.`);
          return;
      }
      if (stage === 'ready_for_booking') {
        return ctx.reply('لم أفهم طلبك. يرجى استخدام الأزرار في لوحة المفاتيح أو الأوامر مثل /book_trip.');
      }
  }

  switch (stage) {
    case 'awaiting_email':
      ctx.session.email = msg;
      ctx.session.stage = 'awaiting_password';
      return ctx.reply('🔒 الرجاء إدخال كلمة المرور:');
    case 'awaiting_password':
      ctx.session.password = msg;
      try {
        await ctx.reply('جاري التحقق من معلومات تسجيل الدخول...');
        const res = await axios.post(`${process.env.API_BASE_URL}/users/signin`, {
          email: ctx.session.email,
          password: ctx.session.password
        });
        ctx.session.token = res.data.token;
        ctx.session.userId = res.data.user.userId;
        linkedUsers[ctx.from.id] = {
            appUserId: ctx.session.userId,
            fullName: res.data.user.fullName || res.data.user.email.split('@')[0],
            appToken: ctx.session.token
        };
        await saveLinkedUsers();
        ctx.session.stage = 'ready_for_booking';
        const fullName = linkedUsers[ctx.from.id].fullName || linkedUsers[ctx.from.id].appUserId;
        return ctx.reply(
          `✅ مرحباً ${fullName}! تم تسجيل الدخول بنجاح.\n\n` +
          `الآن يمكنك البدء في حجز رحلة جديدة بكتابة /book_trip أو عرض رحلاتك السابقة بكتابة /my_bookings.`, 
          Markup.keyboard([['حجز رحلة جديدة', 'رحلاتي']]).resize().oneTime()
        );
      } catch (err) {
        console.error('Login error:', err.response?.data || err.message);
        ctx.session = { ...initState };
        let errorMessage = '❌ فشل تسجيل الدخول. معلومات غير صحيحة أو حساب غير مفعل.';
        if (err.response?.data?.message) {
            errorMessage = `❌ ${err.response.data.message}`;
        }
        return ctx.reply(errorMessage + '\nالرجاء المحاولة مجددًا.\nأدخل بريدك الإلكتروني:');
      }
    case 'awaiting_destination_text':
      ctx.session.destination = msg;
      try {
        const location = await geocodeLocationByName(msg);
        ctx.session.destinationLocation = { latitude: location.latitude, longitude: location.longitude };
        ctx.session.destination = location.displayName; // تحديث اسم الوجهة
        ctx.session.stage = 'awaiting_datetime';
        return ctx.reply(
          `📍 تم تحديد الوجهة: ${location.displayName || msg}\n\n` + 
          '🕓 متى تريد الرحلة؟ (مثال: 2025-06-20 14:00)\nصيغة الوقت: YYYY-MM-DD HH:MM'
        );
      } catch (e) {
        console.error('Geocoding error:', e);
        return ctx.reply('❌ لم أتمكن من تحديد موقع الوجهة. الرجاء إدخال اسم آخر (مثال: نابلس):');
      }
    case 'awaiting_datetime':
      if (!/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(msg)) {
        return ctx.reply('⚠️ صيغة التاريخ غير صحيحة. الرجاء إدخال التاريخ بالشكل: 2025-06-20 14:00');
      }
      ctx.session.datetime = msg;
      if (!ctx.session.userId || !ctx.session.token || !ctx.session.pickupLocation || !ctx.session.destinationLocation) {
        console.error('Missing session data for booking:', ctx.session);
        ctx.session = { ...initState, token: ctx.session.token, userId: ctx.session.userId };
        return ctx.reply('❌ حدث خطأ في جمع معلومات الرحلة. الرجاء البدء من جديد بكتابة /book_trip');
      }
      try {
        const dist = getDistance(ctx.session.pickupLocation, ctx.session.destinationLocation);
        const estimatedFare = +(dist * 4.4).toFixed(2);
        await ctx.reply('جاري تأكيد حجز رحلتك...');
        const tripData = {
          userId: ctx.session.userId,
          startLocation: { latitude: ctx.session.pickupLocation.latitude, longitude: ctx.session.pickupLocation.longitude, address: ctx.session.pickup },
          endLocation: { latitude: ctx.session.destinationLocation.latitude, longitude: ctx.session.destinationLocation.longitude, address: ctx.session.destination },
          distance: dist,
          estimatedFare: estimatedFare,
          paymentMethod: 'cash',
          startTime: ctx.session.datetime
        };
        const config = { headers: { Authorization: `Bearer ${ctx.session.token}` } };
        const bookRes = await axios.post(`${process.env.API_BASE_URL}/trips`, tripData, config);
        await ctx.replyWithMarkdown(`
          ✅ *تم حجز الرحلة بنجاح!*
          \n*رقم الرحلة:* \`${bookRes.data.tripId}\`
          \n*من:* ${ctx.session.pickup}
          \n*إلى:* ${ctx.session.destination}
          \n*المسافة:* ${dist.toFixed(2)} كم
          \n*الأجرة التقديرية:* ${estimatedFare} شيكل
          \n*الوقت المطلوب:* ${ctx.session.datetime}
        `);
        ctx.session = { ...initState, token: ctx.session.token, userId: ctx.session.userId };
        ctx.session.stage = 'ready_for_booking';
      } catch (err) {
        console.error('Booking error details:', err.response?.data || err.message);
        let errorMsg = '❌ حدث خطأ أثناء الحجز. الرجاء المحاولة لاحقًا.';
        if (err.response?.data?.details) {
          errorMsg += `\nالتفاصيل: ${err.response.data.details}`;
        } else if (err.response?.data?.error) {
          errorMsg += `\nالخطأ: ${err.response.data.error}`;
        }
        ctx.reply(errorMsg + '\nيمكنك البدء من جديد بكتابة /book_trip');
        ctx.session = { ...initState, token: ctx.session.token, userId: ctx.session.userId };
      }
      break;
    case 'ready_for_booking': 
      return ctx.reply('لم أفهم طلبك. يرجى استخدام الأزرار في لوحة المفاتيح أو الأوامر مثل /book_trip أو /my_bookings.');
    default:
      return ctx.reply('📝 الرجاء بدء المحادثة بكتابة /start');
  }
});

function getDistance(loc1, loc2) {
  const toRad = (val) => (val * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(loc2.latitude - loc1.latitude);
  const dLon = toRad(loc2.longitude - loc1.longitude);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(loc1.latitude)) * Math.cos(toRad(loc2.latitude)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

bot.launch().then(() => console.log('🚀 TaxiGo Bot started')).catch(console.error);

process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));
