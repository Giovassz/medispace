# 🏥 MediSpace - Aplicación de Citas Médicas

## 📱 Descripción del Proyecto

MediSpace es una aplicación móvil desarrollada en Flutter que permite a los usuarios gestionar citas médicas de manera eficiente y segura. La aplicación conecta pacientes con profesionales médicos, facilitando el agendamiento de consultas y proporcionando herramientas de comunicación y gestión de información médica.

## ✨ Características Principales

### 🔐 Autenticación y Seguridad
- **Login/Registro** con Firebase Authentication
- **Recuperación de contraseña** por email
- **Validación de datos** en tiempo real
- **Protección de información médica** con cifrado

### 👥 Gestión de Usuarios
- **Dos tipos de usuario:** Pacientes y Doctores
- **Perfil personalizable** con información médica
- **Edición de datos** (nombre, edad, lugar de nacimiento, padecimientos)
- **Información profesional** para doctores (especialidad, licencia)

### 📅 Sistema de Citas
- **Agendamiento de citas** en tiempo real
- **Calendario visual** con TableCalendar
- **Verificación de disponibilidad** automática
- **Gestión de estados** (Programada, Confirmada, Completada, Cancelada)
- **Recordatorios** y notificaciones

### 🏥 Especialidades Médicas
- **8 especialidades** disponibles:
  - Medicina General
  - Cardiología
  - Dermatología
  - Pediatría
  - Ginecología
  - Ortopedia
  - Neurología
  - Oftalmología

### 💬 Comunicación
- **Sistema de mensajes** entre pacientes y doctores
- **Interfaz de chat** moderna y intuitiva
- **Notificaciones** de mensajes no leídos

### 🩺 Consejos Médicos
- **Widget de consejos** para aliviar dolores leves
- **Información médica** básica y confiable
- **Advertencias** para consultar médico cuando sea necesario

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter** 3.x
- **Dart** 3.x
- **Material Design 3**
- **Google Fonts** (Poppins)

### Backend y Servicios
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Core**

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  google_fonts: ^6.1.0
  table_calendar: ^3.0.9
  intl: ^0.19.0
```

## 📱 Pantallas Implementadas

### 1. 🔐 Pantalla de Login
- Formulario de autenticación
- Validación de email y contraseña
- Navegación a registro y recuperación de contraseña
- Diseño moderno con gradientes

### 2. 🏠 Pantalla Principal (Home)
- Mensaje de bienvenida personalizado
- Widget "Agendar Cita"
- Widget "Consejos Médicos"
- Lista de especialidades médicas
- Contenido diferenciado por rol de usuario

### 3. 💬 Pantalla de Mensajes
- Lista de conversaciones con doctores
- Avatares personalizados
- Timestamps relativos
- Indicadores de mensajes no leídos

### 4. ⚙️ Pantalla de Configuración
- Información del usuario
- Acceso a edición de perfil
- Configuración de privacidad
- Información sobre la aplicación
- Botón de cerrar sesión

### 5. 👤 Pantalla de Edición de Perfil
- Formulario completo de datos personales
- Campos: nombre, teléfono, edad, lugar de nacimiento
- Campo de padecimientos médicos
- Validaciones y actualización en Firebase

### 6. 🔒 Pantalla de Privacidad
- Información detallada sobre protección de datos
- Políticas de uso de información
- Derechos del usuario
- Información de contacto

### 7. ℹ️ Pantalla "Sobre Nosotros"
- Información de la aplicación
- Misión, visión y valores
- Características principales
- Información de contacto

### 8. 📅 Pantalla de Calendario
- Vista de calendario mensual
- Citas del día seleccionado
- Estados de citas con colores
- Integración con Firebase

### 9. 📋 Pantalla de Citas
- Lista de citas del usuario
- Filtros por estado
- Gestión de citas (confirmar, completar, cancelar)
- Información detallada de cada cita

### 10. 📝 Pantalla de Agendamiento
- Selección de especialidad
- Selección de doctor
- Selección de fecha y hora
- Campos opcionales (motivo, notas)
- Verificación de disponibilidad

## 🗂️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── firebase_options.dart     # Configuración de Firebase
├── models/                   # Modelos de datos
│   ├── user_model.dart
│   ├── appointment_model.dart
│   └── specialty_model.dart
├── screens/                  # Pantallas de la aplicación
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── messages_screen.dart
│   ├── settings_screen.dart
│   ├── edit_profile_screen.dart
│   ├── privacy_screen.dart
│   ├── about_screen.dart
│   ├── calendar_screen.dart
│   ├── appointments_screen.dart
│   ├── book_appointment_screen.dart
│   └── main_navigation_screen.dart
├── services/                 # Servicios de la aplicación
│   ├── auth_service.dart
│   └── appointment_service.dart
└── widgets/                  # Widgets reutilizables
    ├── custom_button.dart
    └── custom_text_field.dart
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.x o superior
- Dart 3.x o superior
- Android Studio / VS Code
- Cuenta de Firebase

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/medispace.git
cd medispace
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
   - Crear proyecto en Firebase Console
   - Habilitar Authentication y Firestore
   - Descargar `google-services.json` (Android)
   - Configurar `firebase_options.dart`

4. **Ejecutar la aplicación**
```bash
flutter run
```

## 🔧 Configuración de Firebase

### Authentication
- Habilitar Email/Password
- Configurar reglas de seguridad

### Firestore Database
- Crear colecciones:
  - `users` - Información de usuarios
  - `appointments` - Citas médicas
  - `doctor_availability` - Disponibilidad de doctores

### Reglas de Seguridad Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📊 Funcionalidades por Rol

### 👨‍⚕️ Doctor
- Ver citas programadas
- Confirmar/cancelar citas
- Gestionar disponibilidad
- Comunicarse con pacientes
- Ver información profesional

### 👤 Paciente
- Agendar citas médicas
- Ver historial de citas
- Recibir consejos médicos
- Comunicarse con doctores
- Gestionar perfil personal

## 🎨 Diseño y UX

### Paleta de Colores
- **Primario:** #667EEA (Azul)
- **Secundario:** #764BA2 (Púrpura)
- **Éxito:** #48BB78 (Verde)
- **Advertencia:** #F6AD55 (Naranja)
- **Error:** #E53E3E (Rojo)
- **Neutro:** #718096 (Gris)

### Tipografía
- **Fuente Principal:** Poppins (Google Fonts)
- **Tamaños:** 12px - 32px
- **Pesos:** 400, 500, 600, 700

### Componentes
- **Botones:** Redondeados con gradientes
- **Tarjetas:** Sombras suaves y bordes redondeados
- **Formularios:** Validación en tiempo real
- **Navegación:** Bottom Navigation Bar

## 🔒 Seguridad y Privacidad

### Protección de Datos
- Cifrado de extremo a extremo
- Autenticación segura con Firebase
- Validación de datos en cliente y servidor
- Cumplimiento con normativas de salud

### Permisos
- Acceso a cámara (futuro)
- Notificaciones push
- Almacenamiento local

## 🧪 Testing

### Pruebas Implementadas
- Pruebas unitarias básicas
- Validación de formularios
- Pruebas de navegación
- Pruebas de integración con Firebase

### Ejecutar Pruebas
```bash
flutter test
```

## 📱 Compatibilidad

### Plataformas Soportadas
- **Android:** API 21+ (Android 5.0+)
- **iOS:** iOS 11.0+
- **Web:** Navegadores modernos

### Dispositivos
- Teléfonos inteligentes
- Tablets
- Escritorio (futuro)

## 🚀 Despliegue

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 📈 Roadmap Futuro

### Versión 2.0
- [ ] Notificaciones push
- [ ] Videollamadas integradas
- [ ] Historial médico completo
- [ ] Prescripciones digitales
- [ ] Integración con laboratorios

### Versión 3.0
- [ ] IA para diagnóstico básico
- [ ] Telemedicina avanzada
- [ ] Integración con wearables
- [ ] Análisis de datos de salud

## 👥 Contribución

### Cómo Contribuir
1. Fork del proyecto
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

### Estándares de Código
- Seguir convenciones de Dart/Flutter
- Documentar funciones complejas
- Escribir pruebas para nuevas funcionalidades
- Mantener coherencia en el diseño

## 📞 Soporte

### Contacto
- **Email:** soporte@medispace.com
- **Teléfono:** +1 (555) 123-4567
- **GitHub Issues:** [Reportar problemas](https://github.com/tu-usuario/medispace/issues)

### Documentación
- [Documentación Flutter](https://docs.flutter.dev)
- [Firebase Docs](https://firebase.google.com/docs)
- [Material Design](https://material.io/design)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🙏 Agradecimientos

- Equipo de Flutter por el framework
- Google por Firebase
- Comunidad de desarrolladores Flutter
- Profesores y compañeros de clase

---

## 📸 Capturas de Pantalla

### Pantalla de Login
![Login Screen](screenshots/login.png)

### Pantalla Principal
![Home Screen](screenshots/home.png)

### Pantalla de Mensajes
![Messages Screen](screenshots/messages.png)

### Pantalla de Configuración
![Settings Screen](screenshots/settings.png)

---

**Desarrollado con ❤️ para mejorar el acceso a la atención médica**

*Última actualización: Diciembre 2024*