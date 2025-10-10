# Instrucciones de Uso - MediSpace

## 🚀 Pasos para Ejecutar la Aplicación

### 1. Configuración Inicial de Firebase

**IMPORTANTE:** Antes de ejecutar la aplicación, debes configurar Firebase:

1. **Crear proyecto Firebase:**
   - Ve a [Firebase Console](https://console.firebase.google.com/)
   - Crea un nuevo proyecto llamado `loginspace-medical`
   - Habilita Authentication con Email/Password

2. **Configurar la aplicación:**
   - Sigue las instrucciones detalladas en `FIREBASE_SETUP.md`
   - Reemplaza el archivo `lib/firebase_options.dart` con tu configuración real

### 2. Ejecutar en Chrome (Web)

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome
```

### 3. Ejecutar en Android Emulator

```bash
# Verificar emuladores disponibles
flutter emulators

# Iniciar emulador (si no está corriendo)
flutter emulators --launch <emulator_name>

# Ejecutar en Android
flutter run
```

## 📱 Funcionalidades de la Aplicación

### Pantalla de Login Principal
- **Campo Email:** Ingresa tu correo electrónico
- **Campo Contraseña:** Ingresa tu contraseña
- **Mostrar/Ocultar Contraseña:** Toca el ícono del ojo
- **Olvidé mi Contraseña:** Toca el enlace para recuperar
- **Crear Cuenta:** Toca para registrarte
- **Iniciar Sesión:** Botón principal para autenticarte

### Pantalla de Registro
- **Email:** Ingresa un email válido
- **Contraseña:** Mínimo 6 caracteres
- **Confirmar Contraseña:** Debe coincidir
- **Crear Cuenta:** Botón para registrarte

### Recuperación de Contraseña
- **Email:** Ingresa el email registrado
- **Enviar:** Recibirás un email de recuperación
- **Reenviar:** Opción para reenviar el email

### Pantalla Principal (Dashboard)
- **Servicios Médicos:** Grid de opciones disponibles
- **Información del Usuario:** Datos de la cuenta actual
- **Cerrar Sesión:** Botón para salir de la aplicación

## 🧪 Pruebas Recomendadas

### 1. Prueba de Registro
1. Abre la aplicación
2. Toca "Crear cuenta"
3. Ingresa un email válido (ej: `test@ejemplo.com`)
4. Crea una contraseña (mínimo 6 caracteres)
5. Confirma la contraseña
6. Toca "Crear Cuenta"
7. ✅ Deberías ver un mensaje de éxito

### 2. Prueba de Login
1. En la pantalla de login
2. Ingresa el email que registraste
3. Ingresa la contraseña
4. Toca "Iniciar Sesión"
5. ✅ Deberías acceder al dashboard

### 3. Prueba de Recuperación de Contraseña
1. Toca "¿Olvidaste tu contraseña?"
2. Ingresa tu email registrado
3. Toca "Enviar Enlace de Recuperación"
4. ✅ Deberías ver confirmación de envío

### 4. Prueba de Validaciones
1. **Email inválido:** Ingresa `test@` (sin dominio)
2. **Contraseña corta:** Ingresa `123` (menos de 6 caracteres)
3. **Campos vacíos:** Deja campos en blanco
4. ✅ Deberías ver mensajes de error apropiados

## 🔧 Solución de Problemas

### Error: "No Firebase App '[DEFAULT]' has been created"
**Solución:** Verifica que hayas configurado correctamente `firebase_options.dart`

### Error: "The email address is badly formatted"
**Solución:** Asegúrate de que el método Email/Password esté habilitado en Firebase Console

### Error: "Network error"
**Solución:** Verifica tu conexión a internet y que el proyecto Firebase esté activo

### La aplicación no se ejecuta en Chrome
**Solución:**
```bash
# Limpiar caché
flutter clean
flutter pub get
flutter run -d chrome
```

### La aplicación no se ejecuta en Android
**Solución:**
```bash
# Verificar dispositivos
flutter devices

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

## 📊 Características Técnicas

- **Framework:** Flutter 3.9.2+
- **Autenticación:** Firebase Authentication
- **Plataformas:** Web (Chrome) y Android
- **Diseño:** Material Design con tema médico
- **Validación:** Formularios con validación en tiempo real
- **Navegación:** Flujo completo de autenticación

## 🎨 Personalización

### Cambiar Colores
Los colores principales están definidos en los archivos de pantalla:
- **Primario:** `Color(0xFF667EEA)` (Azul)
- **Secundario:** `Color(0xFF764BA2)` (Morado)
- **Éxito:** `Color(0xFF48BB78)` (Verde)
- **Error:** `Color(0xFFE53E3E)` (Rojo)

### Cambiar Textos
Los textos están en español y se pueden modificar en cada pantalla:
- Títulos y subtítulos
- Placeholders de campos
- Mensajes de error
- Botones y enlaces

## 📝 Notas Importantes

1. **Configuración Firebase:** Es obligatoria para el funcionamiento
2. **Internet:** Requerido para autenticación
3. **Datos de Prueba:** Usa emails reales para probar recuperación
4. **Seguridad:** No compartas credenciales de Firebase
5. **Backup:** Guarda una copia de tu configuración

## 🆘 Soporte

Si encuentras problemas:
1. Revisa la consola de Flutter para errores
2. Verifica la configuración de Firebase
3. Consulta la documentación en `README.md`
4. Revisa las instrucciones en `FIREBASE_SETUP.md`

---

**¡Disfruta usando MediSpace! 🏥✨**
