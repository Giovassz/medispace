# 🏥 MediSpace - Sistema de Gestión Médica

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white" alt="Web" />
</div>

<br>

> **MediSpace** es una aplicación móvil y web desarrollada en Flutter que facilita la gestión de citas médicas, proporcionando una interfaz moderna e intuitiva para pacientes y profesionales de la salud.

## 📱 Características Principales

### 🔐 Autenticación Segura
- **Login/Registro** con email y contraseña
- **Recuperación de contraseña** por email
- **Validación en tiempo real** de formularios
- **Integración con Firebase Authentication**

### 📅 Gestión de Citas
- **Calendario interactivo** para visualizar citas
- **Reserva de citas** por especialidad médica
- **Lista de citas** con estado y detalles
- **Sistema de notificaciones**

### 🩺 Especialidades Médicas
- **Cardiología** - Enfermedades del corazón
- **Dermatología** - Cuidado de la piel
- **Neurología** - Sistema nervioso
- **Pediatría** - Medicina infantil
- **Ginecología** - Salud femenina
- **Traumatología** - Lesiones óseas y musculares

### 👤 Perfil de Usuario
- **Gestión de datos personales**
- **Historial de citas**
- **Configuración de cuenta**
- **Cerrar sesión seguro**

## 🚀 Tecnologías Utilizadas

<table>
<tr>
<td align="center" width="50%">

### Frontend
- **Flutter 3.9.2+** - Framework de desarrollo
- **Material Design** - Sistema de diseño
- **Google Fonts** - Tipografías personalizadas
- **Responsive Design** - Adaptable a diferentes pantallas

</td>
<td align="center" width="50%">

### Backend & Servicios
- **Firebase Core** - Plataforma de desarrollo
- **Firebase Auth** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos NoSQL
- **Provider** - Gestión de estado

</td>
</tr>
</table>

## 📋 Requisitos del Sistema

### Desarrollo
- **Flutter SDK** 3.9.2 o superior
- **Dart SDK** 3.0 o superior
- **Android Studio** / **VS Code**
- **Git** para control de versiones

### Plataformas Soportadas
- ✅ **Android** (API 21+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **iOS** (configuración disponible)
- ✅ **Windows** (configuración disponible)

## 🛠️ Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/medispace.git
cd medispace
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Configurar Firebase
1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Habilitar **Authentication** con Email/Password
3. Configurar **Cloud Firestore**
4. Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
5. Reemplazar archivos en las carpetas correspondientes

### 4. Configurar Firebase Options
```bash
# Generar configuración automática
flutterfire configure
```

### 5. Ejecutar la Aplicación

#### En Web (Chrome)
```bash
flutter run -d chrome
```

#### En Android
```bash
flutter run
```

#### En iOS (macOS)
```bash
flutter run -d ios
```

## 📱 Capturas de Pantalla

<div align="center">

| Login | Registro | Dashboard |
|-------|----------|-----------|
| ![Login](docs/screenshots/login.png) | ![Registro](docs/screenshots/register.png) | ![Dashboard](docs/screenshots/dashboard.png) |

| Citas | Perfil | Calendario |
|-------|--------|------------|
| ![Citas](docs/screenshots/appointments.png) | ![Perfil](docs/screenshots/profile.png) | ![Calendario](docs/screenshots/calendar.png) |

</div>

## 🏗️ Arquitectura del Proyecto

```
lib/
├── 📁 models/              # Modelos de datos
│   ├── user_model.dart
│   ├── appointment_model.dart
│   └── specialty_model.dart
├── 📁 screens/             # Pantallas de la aplicación
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── appointments_screen.dart
│   ├── book_appointment_screen.dart
│   ├── calendar_screen.dart
│   ├── profile_screen.dart
│   └── forgot_password_screen.dart
├── 📁 services/            # Servicios y lógica de negocio
│   ├── auth_service.dart
│   └── appointment_service.dart
├── 📁 widgets/             # Widgets reutilizables
│   ├── custom_button.dart
│   └── custom_text_field.dart
├── firebase_options.dart   # Configuración de Firebase
└── main.dart              # Punto de entrada
```

## 🧪 Pruebas

### Ejecutar Tests
```bash
flutter test
```

### Pruebas de Integración
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 Build y Deployment

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (AAB)
```bash
flutter build appbundle --release
```

### Web
```bash
flutter build web --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Para contribuir:

1. **Fork** el proyecto
2. **Crea** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre** un Pull Request

### Guías de Contribución
- Sigue las convenciones de código de Flutter
- Añade tests para nuevas funcionalidades
- Actualiza la documentación cuando sea necesario
- Usa commits descriptivos

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Autores

- **Tu Nombre** - *Desarrollo inicial* - [@tu-github](https://github.com/tu-github)

## 🙏 Agradecimientos

- **Flutter Team** por el increíble framework
- **Firebase Team** por los servicios backend
- **Comunidad Flutter** por el apoyo y recursos

## 📞 Soporte

Si tienes preguntas o necesitas ayuda:

- 📧 **Email**: tu-email@ejemplo.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/tu-usuario/medispace/issues)
- 💬 **Discusiones**: [GitHub Discussions](https://github.com/tu-usuario/medispace/discussions)

---

<div align="center">
  <p>Hecho con ❤️ usando Flutter</p>
  <p>
    <a href="#-medispace---sistema-de-gestión-médica">⬆️ Volver arriba</a>
  </p>
</div>
