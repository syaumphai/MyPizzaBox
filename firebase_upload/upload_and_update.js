const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// === ตั้งค่าตามโปรเจกต์ของคุณ ===
const serviceAccount = require('./serviceAccountKey.json');
const imagesDir = 'assets/menu_images'; // โฟลเดอร์รูป
const firestoreCollection = 'menus';    // ชื่อ collection ใน Firestore
const matchField = 'image';             // field ที่ใช้ match ชื่อไฟล์
const urlField = 'imageUrl';            // field ที่จะอัปเดต download URL

// === เริ่มต้น Firebase Admin ===
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'anoulack-d185e.appspot.com', // เปลี่ยนตาม bucket จริง
});
const db = admin.firestore();
const bucket = admin.storage().bucket();

async function uploadAndUpdate() {
  const files = fs.readdirSync(imagesDir);

  for (const fileName of files) {
    const filePath = path.join(imagesDir, fileName);
    const dest = `menu_images/${fileName}`;

    // อัปโหลดไฟล์ขึ้น Storage
    await bucket.upload(filePath, {
      destination: dest,
      public: true,
      metadata: {
        cacheControl: 'public,max-age=31536000',
      },
    });

    // สร้าง public URL (แบบ signed URL)
    const file = bucket.file(dest);
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: '03-09-2491', // วันหมดอายุไกล ๆ
    });

    console.log(`Uploaded ${fileName}: ${url}`);

    // ค้นหา document ที่ field image ตรงกับชื่อไฟล์
    const snapshot = await db.collection(firestoreCollection)
      .where(matchField, '==', fileName)
      .get();

    if (snapshot.empty) {
      console.log(`No document found for ${fileName}`);
      continue;
    }

    // อัปเดต field imageUrl
    for (const doc of snapshot.docs) {
      await doc.ref.update({ [urlField]: url });
      console.log(`Updated Firestore for ${fileName}`);
    }
  }
  console.log('Done!');
}

uploadAndUpdate().catch(console.error); 