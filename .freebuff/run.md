# Run doc — Munnarivu disaster preparedness app (Flutter)

## Reproduce the app artifacts
1. From the project root:
   ```
   flutter pub get
   flutter build web --release
   ```
   Outputs `build/web` (the release web bundle). No `.env` files are used —
   the backend base URL is configurable at runtime via the in-app Server
   Settings dialog (`ApiService.setBaseUrl`), so nothing needs copying from
   the main checkout.

## Run the server (web preview)
2. Serve `build/web` with Python's static server on port 8080 (port 9090 is
   already taken on this machine):
   ```
   powershell -NoProfile -Command "(Start-Process -FilePath 'python.exe' -ArgumentList '-m','http.server','8080','--bind','127.0.0.1','--directory','build/web' -RedirectStandardOutput '.freebuff/preview.log' -RedirectStandardError '.freebuff/preview.log.err' -WindowStyle Hidden -PassThru).Id"
   ```
3. Verify it survived: `powershell -NoProfile -Command "Get-Process -Id <pid>"`.
4. Verify the URL answers: `curl -I http://127.0.0.1:8080/`.
   Register URL: `http://127.0.0.1:8080/`.

## Native mobile/desktop run (full functionality)
- Windows desktop: `flutter run -d windows` (backend API reachable at the
  default `ApiService.baseUrl`).
- Chrome dev run with hot reload: `flutter run -d chrome --web-port 8080`.
- Backend: the FastAPI service lives in `backend/` (`uvicorn main:app`).
  The web build renders screens with mock data if the backend is unreachable.
