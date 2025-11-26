# 🔒 Configuración de Reglas de Seguridad de Firestore

## ⚠️ Problema Actual

Si estás recibiendo el error `[cloud_firestore/permission-denied] Missing or insufficient permissions`, significa que las reglas de seguridad de Firestore no están configuradas correctamente.

## 📋 Solución: Configurar Reglas en Firebase Console

### Paso 1: Acceder a Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, ve a **Firestore Database**
4. Haz clic en la pestaña **Rules** (Reglas)

### Paso 2: Copiar las Reglas

Copia y pega las siguientes reglas en el editor de reglas de Firebase:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Reglas para la colección de usuarios
    match /users/{userId} {
      // Permitir lectura y escritura solo al propio usuario
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Permitir lectura a todos los usuarios autenticados (para buscar doctores)
      allow read: if request.auth != null;
    }
    
    // Reglas para la colección de citas
    match /appointments/{appointmentId} {
      // Permitir lectura si el usuario es el paciente o el doctor de la cita
      allow read: if request.auth != null && (
        resource.data.patientId == request.auth.uid ||
        resource.data.doctorId == request.auth.uid
      );
      
      // Permitir escritura si el usuario es el paciente o el doctor
      allow create: if request.auth != null && (
        request.resource.data.patientId == request.auth.uid ||
        request.resource.data.doctorId == request.auth.uid
      );
      
      allow update, delete: if request.auth != null && (
        resource.data.patientId == request.auth.uid ||
        resource.data.doctorId == request.auth.uid
      );
    }
    
    // Reglas para otras colecciones (si las hay)
    match /{document=**} {
      // Denegar acceso por defecto a otras colecciones
      allow read, write: if false;
    }
  }
}
```

### Paso 3: Publicar las Reglas

1. Haz clic en el botón **Publish** (Publicar)
2. Espera a que se confirme la publicación
3. Las reglas se aplicarán inmediatamente

## 🔍 Explicación de las Reglas

### Colección `users`
- **Lectura/Escritura propia**: Cada usuario puede leer y escribir solo su propio documento
- **Lectura general**: Todos los usuarios autenticados pueden leer documentos de otros usuarios (necesario para buscar doctores)

### Colección `appointments`
- **Lectura**: Solo el paciente o el doctor asignado pueden leer una cita
- **Creación**: Solo el paciente o el doctor pueden crear citas
- **Actualización/Eliminación**: Solo el paciente o el doctor pueden modificar o eliminar citas

## ⚡ Reglas Temporales para Desarrollo (NO USAR EN PRODUCCIÓN)

Si necesitas reglas más permisivas solo para desarrollo y pruebas, puedes usar temporalmente:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ ADVERTENCIA**: Estas reglas permiten que cualquier usuario autenticado pueda leer y escribir en cualquier colección. **NO uses estas reglas en producción**.

## ✅ Verificación

Después de configurar las reglas:

1. Recarga la aplicación
2. Intenta iniciar sesión nuevamente
3. El error de permisos debería desaparecer

## 🆘 Si el Problema Persiste

1. **Verifica que Authentication esté habilitado**:
   - Ve a Authentication en Firebase Console
   - Asegúrate de que Email/Password esté habilitado

2. **Verifica que el usuario esté autenticado**:
   - El error solo debería ocurrir si el usuario no está autenticado
   - Asegúrate de que el login se complete correctamente

3. **Verifica las reglas publicadas**:
   - Vuelve a Firestore > Rules
   - Confirma que las reglas se publicaron correctamente
   - Revisa que no haya errores de sintaxis

4. **Limpia la caché del navegador** (si estás en web):
   - Presiona `Ctrl + Shift + Delete`
   - Limpia la caché y recarga la página

## 📚 Referencias

- [Documentación de Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Guía de Reglas de Seguridad](https://firebase.google.com/docs/firestore/security/rules-structure)

