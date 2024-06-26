:: Update/Fetch vcpkg repository
IF EXIST vcpkg (
        cd vcpkg
        git reset --hard
        git pull origin
) ELSE (
        git clone https://github.com/Microsoft/vcpkg.git
        cd vcpkg
)

:: Build vcpkg
call bootstrap-vcpkg.bat

:: Optimize the debug libraries
copy ..\helper\windows.cmake scripts\toolchains\windows.cmake

:: Copy custom portfiles
:: ICU static data file
xcopy /Y /I /E ..\icu-easyrpg ports\icu-easyrpg
:: fluidsynth without glib dependency
xcopy /Y /I /E ..\fluidsynth-easyrpg ports\fluidsynth-easyrpg
:: lhasa (delete when upstream port accepted)
xcopy /Y /I /E ..\lhasa-easyrpg ports\lhasa-easyrpg
