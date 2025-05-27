const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../utils/cloudinary');

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: async (req, file) => {
    return {
      folder: 'Taxi-Go/drivers',
      public_id: `driver_${req.params.id}_${Date.now()}`,
      allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
      transformation: [
        { width: 800, height: 800, crop: 'limit' },
        { quality: 'auto:best' },
        { format: 'webp' }
      ]
    };
  }
});

const fileFilter = (req, file, cb) => {
        console.log('⏺️ multer fileFilter called');

  console.log('Mimetype:', file.mimetype);
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('الملف المرفوع ليس صورة! يرجى رفع ملف صالح'), false);
  }
};


const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB كحد أقصى
  }
});

module.exports = upload;