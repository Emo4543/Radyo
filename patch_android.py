import glob
import os
import re
import sys

root = sys.argv[1]
main = os.path.join(root, 'android', 'app', 'src', 'main')

# ---- AndroidManifest ----
mp = os.path.join(main, 'AndroidManifest.xml')
m = open(mp, encoding='utf-8').read()

perms = '''    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
'''
m = m.replace('<application', perms + '    <application\n        android:usesCleartextTraffic="true"', 1)
m = re.sub(r'android:label="[^"]*"', 'android:label="Zenith Radyo"', m, count=1)

svc = '''
        <service android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>
        <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>
    '''
m = m.replace('</application>', svc + '</application>', 1)
open(mp, 'w', encoding='utf-8').write(m)

# ---- MainActivity -> AudioServiceActivity ----
for f in glob.glob(os.path.join(main, '**', 'MainActivity.*'), recursive=True):
    t = open(f, encoding='utf-8').read()
    t = t.replace('io.flutter.embedding.android.FlutterActivity',
                  'com.ryanheise.audioservice.AudioServiceActivity')
    t = t.replace('FlutterActivity()', 'AudioServiceActivity()')
    t = t.replace('FlutterActivity', 'AudioServiceActivity')
    open(f, 'w', encoding='utf-8').write(t)

# ---- Adaptive ikon (yildirim Z) ----
res = os.path.join(main, 'res')
os.makedirs(os.path.join(res, 'drawable'), exist_ok=True)
os.makedirs(os.path.join(res, 'values'), exist_ok=True)
os.makedirs(os.path.join(res, 'mipmap-anydpi-v26'), exist_ok=True)
open(os.path.join(res, 'drawable', 'ic_launcher_foreground.xml'), 'w').write('''<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#00E5FF"
        android:pathData="M34,30 L82,30 L82,41 L56,57 L76,57 L32,80 L46,62 L28,62 L56,43 L34,43 Z" />
</vector>
''')
open(os.path.join(res, 'values', 'ic_launcher_background.xml'), 'w').write('''<resources>
    <color name="ic_launcher_background">#0A0E1A</color>
</resources>
''')
adaptive = '''<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
'''
for n in ('ic_launcher', 'ic_launcher_round'):
    open(os.path.join(res, 'mipmap-anydpi-v26', n + '.xml'), 'w').write(adaptive)

print('Android yamasi uygulandi')
