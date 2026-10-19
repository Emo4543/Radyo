# Zenith Radyo

Türkiye'nin en çok dinlenen radyolarını canlı dinleten, Flutter ile yazılmış Android uygulaması.

## Özellikler
- Kayıt / giriş (şifreler tuzlanmış ve çok turlu SHA-256 ile saklanır)
- Profil, favoriler, açık/koyu/sistem tema
- Türkiye istasyonları (radio-browser.info, dinlenme sayısına göre sıralı), arama, çevrimdışı önbellek
- Arka planda çalma, bildirim ve kilit ekranı kontrolü
- Çalan şarkı bilgisi (yayın ICY metadata gönderiyorsa), ses seviyesi, uyku zamanlayıcı
- Yayıncı paneli: kendi Icecast/Shoutcast kanalını ekle ve dinle

## Bilgisayarsız derleme (GitHub Actions)
1. Bu dosyaları yeni bir GitHub deposunun ana dizinine yükle.
2. `workflow.yml` içeriğini `.github/workflows/build.yml` olarak kaydet.
3. Actions sekmesinde yeşil tik gelince APK şu adreste olur:
   `https://github.com/KULLANICI/DEPO/releases/download/radyo/ZenithRadyo.apk`
4. Telefonda APK'yı aç, "bilinmeyen kaynaklardan yükle" iznini ver.

## Bilgisayarda derleme
```
flutter create --org com.zenith --project-name zenith_radyo --platforms=android app
cp app_pubspec.yaml app/pubspec.yaml
cp *.dart app/lib/
python3 patch_android.py app
cd app && flutter pub get && flutter run
```
APK için: `flutter build apk --release`

## Notlar
- iOS bu depoyla derlenemez: Apple, Mac ve Xcode gerektirir.
- Hesaplar cihazda saklanır, cihazlar arası senkron yoktur. Firebase Authentication'a geçmek için sadece `auth_service.dart` dosyasını değiştirmek yeterlidir.
- Yayıncı paneli canlı yayını sunucuya göndermez. Yayın için bir Icecast/Shoutcast/AzuraCast sunucusu gerekir, panel o sunucunun adresini dinletir.
