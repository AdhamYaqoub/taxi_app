// index.js (Bot Backend Server - Web App Login)

require('dotenv').config(); // تحميل المتغيرات البيئية من .env
const { Telegraf, Markup } = require('telegraf'); // مكتبة التيليجرام
const axios = require('axios'); // لعمل طلبات HTTP
const express = require('express'); // لإنشاء سيرفر الويب
const fs = require('fs').promises; // للتعامل مع الملفات بشكل غير متزامن (لتخزين حالة المستخدمين)

// استخراج المتغيرات من .env
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const YOUR_BACKEND_API_BASE_URL = process.env.YOUR_BACKEND_API_BASE_URL;
const WEB_APP_LOGIN_URL = process.env.WEB_APP_LOGIN_URL;

if (!TELEGRAM_BOT_TOKEN || !YOUR_BACKEND_API_BASE_URL || !WEB_APP_LOGIN_URL) {
  console.error('Environment variables are missing. Please check your .env file.');
  process.exit(1);
}

const bot = new Telegraf(TELEGRAM_BOT_TOKEN);
const app = express();
app.use(express.json()); // لفك تشفير JSON في طلبات POST

// --- إدارة ربط المستخدمين (Persistent Linked Users) ---
// { telegramUserId: { appUserId: '...', fullName: '...', appToken: '...' } }
let linkedUsers = {}; 
const LINKED_USERS_FILE = 'linked_users.json'; // ملف لتخزين الروابط بشكل دائم

// دالة لتحميل المستخدمين المرتبطين من الملف
async function loadLinkedUsers() {
  try {
    const data = await fs.readFile(LINKED_USERS_FILE, 'utf8');
    linkedUsers = JSON.parse(data);
    console.log(`Loaded ${Object.keys(linkedUsers).length} linked users from file.`);
  } catch (error) {
    if (error.code === 'ENOENT') {
      console.log('linked_users.json not found, starting with empty linked users.');
      linkedUsers = {};
    } else {
      console.error('Error loading linked users from file:', error);
    }
  }
}

// دالة لحفظ المستخدمين المرتبطين إلى الملف
async function saveLinkedUsers() {
  try {
    await fs.writeFile(LINKED_USERS_FILE, JSON.stringify(linkedUsers, null, 2), 'utf8');
    console.log('Linked users saved to file.');
  } catch (error) {
    console.error('Error saving linked users to file:', error);
  }
}

// تحميل المستخدمين عند بدء البوت
loadLinkedUsers();


// --- 1. نقطة نهاية لتقديم صفحة تسجيل الدخول Web App ---
// هذه الصفحة سيفتحها Telegram Web App
app.get('/telegram_login', (req, res) => {
  const telegramUserId = req.query.user_id; // معرف المستخدم من تيليجرام
  if (!telegramUserId) {
    return res.status(400).send('Telegram User ID is missing.');
  }

  // أرسل صفحة HTML بسيطة لتسجيل الدخول
  // في الإنتاج، هذه يمكن أن تكون صفحة HTML/JS أكثر تعقيداً أو حتى تطبيق Flutter Web
  // الأهم هو أن JavaScript في هذه الصفحة سيتصل بـ API الخاص بك لتسجيل الدخول
  res.send(`
    <!DOCTYPE html>
    <html lang="ar" dir="rtl">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>تسجيل الدخول للتطبيق</title>
        <style>
            body { font-family: 'Tajawal', sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; background-color: #f0f2f5; margin: 0; }
            .login-container { background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 100%; max-width: 400px; text-align: center; }
            h2 { color: #333; margin-bottom: 20px; }
            input { width: calc(100% - 20px); padding: 10px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px; }
            button { background-color: #ffc107; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%; }
            button:hover { background-color: #e0a800; }
            .message { margin-top: 15px; color: red; }
            .success { color: green; }
        </style>
    </head>
    <body>
        <div class="login-container">
            <h2>تسجيل الدخول لتطبيق الرحلات</h2>
            <p>يرجى تسجيل الدخول باستخدام حسابك في التطبيق لربطه بتيليجرام.</p>
            <input type="email" id="email" placeholder="البريد الإلكتروني" required>
            <input type="password" id="password" placeholder="كلمة المرور" required>
            <button onclick="login()">تسجيل الدخول</button>
            <p id="message" class="message"></p>
        </div>

        <script>
            // استخراج معرف المستخدم من تيليجرام من الـ URL
            const urlParams = new URLSearchParams(window.location.search);
            const telegramUserId = urlParams.get('user_id');

            // روابط APIs
            const yourBackendApiBaseUrl = "${YOUR_BACKEND_API_BASE_URL}";
            // هذا الرابط يشير إلى نقطة النهاية في خادم البوت نفسه!
            const botBackendLinkApiUrl = window.location.origin + '/api/link_telegram_user'; 

            async function login() {
                const email = document.getElementById('email').value;
                const password = document.getElementById('password').value;
                const messageDiv = document.getElementById('message');
                messageDiv.textContent = ''; // مسح الرسائل السابقة
                messageDiv.className = 'message'; // إعادة تعيين الفئة

                if (!email || !password) {
                    messageDiv.textContent = 'يرجى إدخال البريد الإلكتروني وكلمة المرور.';
                    return;
                }

                try {
                    // 1. استدعاء الـ API الخاص بك لتسجيل الدخول
                    const response = await fetch(\`\${yourBackendApiBaseUrl}/users/signin\`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({ email, password })
                    });

                    const data = await response.json();

                    if (response.ok && data.success) {
                        messageDiv.className = 'message success';
                        messageDiv.textContent = 'تم تسجيل الدخول بنجاح! جاري ربط الحساب...';
                        
                        // 2. إذا نجح تسجيل الدخول، أبلغ خادم البوت بربط الحساب
                        await sendLoginSuccessToBotBackend(data.user._id, data.user.fullName || data.user.email.split('@')[0], data.token);

                        messageDiv.textContent = 'تم ربط الحساب بنجاح. يمكنك العودة إلى تيليجرام.';
                        // إغلاق الـ WebApp تلقائياً بعد الربط الناجح
                        if (window.Telegram && window.Telegram.WebApp) {
                          window.Telegram.WebApp.close();
                        }
                    } else {
                        messageDiv.textContent = data.message || 'فشل تسجيل الدخول.';
                    }
                } catch (error) {
                    messageDiv.textContent = 'حدث خطأ غير متوقع: ' + error.message;
                    console.error('Login error:', error);
                }
            }

            // دالة لإبلاغ خادم البوت بنجاح تسجيل الدخول وربط المستخدمين
            async function sendLoginSuccessToBotBackend(appUserId, fullName, appToken) {
              try {
                  const response = await fetch(botBackendLinkApiUrl, {
                      method: 'POST',
                      headers: {
                          'Content-Type': 'application/json',
                          'Authorization': \`Bearer \${appToken}\` // إرسال التوكن لغرض التحقق (اختياري، يمكنك التحقق من التوكن في البوت باك إند)
                      },
                      body: JSON.stringify({ telegramUserId, appUserId, fullName })
                  });
                  const data = await response.json();
                  if (!response.ok || !data.success) {
                      console.error('Failed to link Telegram user:', data.message);
                      document.getElementById('message').textContent += ' (فشل ربط التيليجرام: ' + (data.message || 'خطأ غير معروف') + ')';
                  }
              } catch (error) {
                  console.error('Error linking Telegram user:', error);
                  document.getElementById('message').textContent += ' (خطأ في ربط التيليجرام: ' + error.message + ')';
              }
            }

            // إذا كان هذا في بيئة Telegram WebApp، قم بتهيئة WebApp
            if (window.Telegram && window.Telegram.WebApp) {
              window.Telegram.WebApp.ready();
              // يمكنك استخدام window.Telegram.WebApp لضبط الألوان، وإخفاء الأزرار، إلخ.
            }
        </script>
    </body>
    </html>
  `);
});

// --- 2. نقطة نهاية (Endpoint) لخادم البوت لربط حساب المستخدم بالتيليجرام ---
// هذه نقطة النهاية سيستدعيها JavaScript في صفحة تسجيل الدخول بعد نجاح الـ sign-in
app.post('/api/link_telegram_user', async (req, res) => {
  const { telegramUserId, appUserId, fullName } = req.body;
  const userAppToken = req.headers.authorization?.split(' ')[1]; // يمكنك استخدام هذا التوكن للتحقق الإضافي

  if (!telegramUserId || !appUserId || !fullName) {
    return res.status(400).json({ success: false, message: 'بيانات غير مكتملة للربط.' });
  }

  try {
    // هنا يمكنك إضافة منطق للتحقق من userAppToken مع الـ API الخاص بك إذا أردت المزيد من الأمان.
    // مثلاً، إرسال التوكن إلى API لـ '/api/users/verifyToken' إن وُجد.
    // حالياً، نثق بأن الـ JavaScript في صفحتنا قد قام بالمصادقة الصحيحة.

    // تخزين العلاقة بين Telegram user ID و App user ID في قاعدة بيانات خادم البوت
    // (حالياً، كائن في الذاكرة ثم يتم حفظه في ملف JSON)
    linkedUsers[telegramUserId] = { appUserId, fullName, appToken: userAppToken }; // حفظ التوكن أيضاً للاستخدام المستقبلي
    await saveLinkedUsers(); // حفظ الروابط بشكل دائم

    console.log(`Linked Telegram user ${telegramUserId} with App user ${appUserId} (${fullName})`);
    res.status(200).json({ success: true, message: 'تم ربط حساب تيليجرام بنجاح.' });
  } catch (error) {
    console.error('Error linking Telegram user:', error);
    res.status(500).json({ success: false, message: 'فشل ربط حساب تيليجرام.' });
  }
});


// --- 3. منطق بوت التيليجرام ---

// أمر /start: يرحب بالمستخدم ويقدم زر تسجيل الدخول
bot.start(async (ctx) => {
  const telegramUserId = ctx.from.id;
  const user = linkedUsers[telegramUserId];

  if (user) {
    // المستخدم مسجل الدخول بالفعل
    return ctx.reply(`مرحباً ${user.fullName}! حسابك مرتبط بالفعل. كيف يمكنني مساعدتك في حجز رحلة؟`, Markup.keyboard([
        ['حجز رحلة جديدة', 'رحلاتي'] // أزرار لعمليات مستقبلية
    ]).resize().oneTime());
  } else {
    // المستخدم غير مسجل الدخول، يقدم زر تسجيل الدخول كـ WebApp
    return ctx.reply(
      'أهلاً بك في بوت حجز الرحلات! لتبدأ، يرجى تسجيل الدخول أو ربط حسابك في التطبيق.',
      Markup.inlineKeyboard([
        Markup.button.webApp('تسجيل الدخول / ربط الحساب', `${WEB_APP_LOGIN_URL}?user_id=${telegramUserId}`),
      ])
    );
  }
});

// التعامل مع أوامر حجز الرحلة وغيرها (تتطلب أن يكون المستخدم مرتبطاً)
bot.command('book_trip', async (ctx) => {
  const telegramUserId = ctx.from.id;
  const user = linkedUsers[telegramUserId];

  if (!user) {
    return ctx.reply('يجب عليك تسجيل الدخول وربط حسابك أولاً لاستخدام هذه الميزة. استخدم أمر /start.');
  }
  
  // هنا تبدأ منطق حجز الرحلة خطوة بخطوة، يمكنك استخدام ctx.wizard أو state management
  // ctx.session.bookingStep = 'origin';
  // ctx.reply(`أهلاً بك ${user.fullName}! ما هي نقطة الانطلاق لرحلتك؟`);
  ctx.reply(`أهلاً بك ${user.fullName}! ميزة حجز الرحلات قيد التطوير. يمكنك لاحقاً تحديد نقطة الانطلاق والوجهة والتاريخ.`);
});

bot.command('my_bookings', async (ctx) => {
  const telegramUserId = ctx.from.id;
  const user = linkedUsers[telegramUserId];

  if (!user) {
    return ctx.reply('يجب عليك تسجيل الدخول وربط حسابك أولاً لاستخدام هذه الميزة. استخدم أمر /start.');
  }
  
  ctx.reply(`جاري جلب رحلاتك يا ${user.fullName}. (جلب البيانات من الـ API الأصلي: ${YOUR_BACKEND_API_BASE_URL}/users/${user.appUserId}/bookings)`);
  // هنا تستدعي الـ API الخاص بك لجلب رحلات المستخدم، باستخدام user.appToken للمصادقة
  // try {
  //   const response = await axios.get(`${YOUR_BACKEND_API_BASE_URL}/bookings/user/${user.appUserId}`, {
  //     headers: { 'Authorization': `Bearer ${user.appToken}` }
  //   });
  //   // ... عرض الرحلات
  // } catch (err) {
  //   ctx.reply('فشل جلب رحلاتك.');
  // }
});


// التعامل مع أي رسائل نصية أخرى (بعد تسجيل الدخول)
bot.on('text', async (ctx) => {
  const telegramUserId = ctx.from.id;
  const user = linkedUsers[telegramUserId];
  const userMessage = ctx.message.text;

  if (user) {
    // المستخدم مسجل الدخول، يمكنه استخدام الأزرار أو الأوامر
    if (userMessage === 'حجز رحلة جديدة') {
        return ctx.reply(`تمام ${user.fullName}! لنبدأ حجز رحلة جديدة...`);
        // هنا تبدأ منطق حجز الرحلة
    } else if (userMessage === 'رحلاتي') {
        return ctx.reply(`جاري جلب رحلاتك يا ${user.fullName}.`);
        // هنا يتم استدعاء دالة 'my_bookings' أو منطقها
    } else {
        return ctx.reply('لم أفهم طلبك. يمكنك استخدام الأزرار أدناه أو الأوامر مثل /book_trip.');
    }
  } else {
    // المستخدم غير مسجل الدخول، اطلب منه البدء
    return ctx.reply('يرجى تسجيل الدخول أولاً. استخدم أمر /start.');
  }
});


// --- بدء تشغيل السيرفر والبوت ---

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Bot backend server running on port ${PORT}`);
  console.log(`Telegram WebApp login URL: ${WEB_APP_LOGIN_URL}`);
});

// إطلاق البوت
bot.launch().then(() => {
  console.log('Telegram bot launched successfully. Listening for messages...');
}).catch((err) => {
  console.error('Failed to launch Telegram bot:', err);
  process.exit(1); // إغلاق التطبيق إذا فشل البوت في البدء
});

// تمكين إيقاف البوت بشكل جيد
process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));