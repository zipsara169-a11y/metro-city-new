# Metro City Game — සිංහල උපදෙස්

මෙය ඔබ එවූ Godot project එක වැඩිදියුණු කර සකස් කළ Android game project එකයි. City එකේ buildings, roads, windows, trees, street lights සහ parked cars code මඟින්ම නිර්මාණය වෙනවා. අමතර paid asset pack එකක් අවශ්‍ය නැහැ.

## එකතු කළ දේවල්

- කලින්ට වඩා විශාල 3D city එකක් සහ විවිධ උස building
- Third-person character එක සහ ඇවිදීම/දුවීමේ සරල animation
- Mobile joystick, camera rotate touch, RUN සහ JUMP buttons
- Day / Night lighting switch එක
- Park කරලා තියෙන cars, ගස් සහ street lights
- එකතු කරන්න පුළුවන් blue energy cores 8ක් සහ mission counter එක
- Android landscape APK export preset එක
- GitHub Actions මඟින් APK build කරන workflow එක

## GitHub එකෙන් APK හදාගන්න පියවර

1. GitHub account එකට log වෙලා **New repository** තෝරන්න. නම `metro-city-game` වගේ එකක් දෙන්න.
2. මේ ZIP file එක extract කරන්න.
3. Extract කරපු folder එක ඇතුළේ තියෙන **සියලුම files සහ folders** repository එකේ root එකට upload කරන්න.
4. `.github` කියන hidden folder එකත් upload වුණාද බලන්න. ඒ folder එකේ `workflows/android-apk.yml` file එක තියෙන්න ඕන.
5. `Commit changes` කරන්න.
6. Repository එකේ **Actions** tab එකට යන්න.
7. `Build Android APK` workflow එක run වෙනවා. අවසන් වුණාම completed run එක open කරන්න.
8. පහළ **Artifacts** යටතේ `MetroCity-Android-APK` download කරන්න.
9. Download වුණු ZIP එක extract කරලා ඇතුළේ තියෙන `MetroCity.apk` phone එකට install කරන්න. මේක testing සඳහා debug key එකකින් sign කරන APK එකක්; Play Store එකට publish කරන release APK එකක් නොවේ.

## Game controls

**Phone:** වම් පැත්තේ joystick එකෙන් move කරන්න. දකුණු පැත්ත drag කරලා camera එක හරවන්න. RUN අල්ලගෙන ඉන්නකොට දුවනවා. JUMP ඔබලා පනින්න. DAY / NIGHT button එකෙන් ආලෝකය වෙනස් කරන්න.

**PC:** WASD / Arrow keys move, mouse camera, Shift run, Space jump, Esc mouse release.

## වැදගත්

මෙය මුල් prototype එකට වඩා විශාල වැඩිදියුණු කිරීමක්. නමුත් licensed 4K textures, mocap character animation, real traffic AI, sound effects සහ story missions වගේ AAA photorealistic features තවම නැහැ. ඒවාට වෙනම 3D models, textures, audio files සහ තවත් development අවශ්‍යයි. මේ version එකෙන් playable city foundation එකක් සහ GitHub APK build ක්‍රමයක් ලැබෙනවා.
