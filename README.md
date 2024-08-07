# App Topografia

App Topografia es una aplicación Flutter desplegada en Firebase Hosting y Android que permite a los Administradores crear y gestionar salas para topógrafos, con funcionalidades de ubicación en tiempo real y métricas geográficas.

## Deploy
- **Hosting URL**: [https://apps-1bac3.web.app](https://apps-1bac3.web.app)<br>
- **App**: app-topografia.apk
- **Video**: [https://youtu.be/ODIuQYLrvgs](https://youtu.be/ODIuQYLrvgs)

## Características

- **Autenticación**: Registro y inicio de sesión para administradores.
- **Gestión de Salas**: Crear, eliminar y gestionar salas de topografía.
- **Ubicación en Tiempo Real**: Seguimiento de la ubicación de los usuarios dentro de una sala.
- **Métricas Geográficas**: Cálculo del área y perímetro de un polígono formado por las ubicaciones de los usuarios.
- **Notificaciones**: Notificaciones en tiempo real sobre cambios en las ubicaciones y estados de los usuarios.

## Requisitos del Sistema

- Flutter SDK
- Firebase Account
- Android Studio (para despliegue en Android)
- Navegador web (para Firebase Hosting)

## Instalación

### Configuración del Proyecto

1. **Clonar el repositorio**:

    ```bash
    git clone https://github.com/tu_usuario/app_topografia.git
    cd app_topografia
    ```

2. **Instalar dependencias**:

    ```bash
    flutter pub get
    ```

3. **Configurar Firebase**:

    - **Firebase Web**:
      - Agrega tu archivo `firebase_options.dart` en el directorio `lib` con las configuraciones obtenidas desde el [Firebase Console](https://console.firebase.google.com/).

    - **Firebase Android**:
      - Añade el archivo `google-services.json` a la carpeta `android/app`.

### Despliegue en Firebase Hosting

1. **Inicializar Firebase Hosting**:

    ```bash
    firebase init hosting
    ```

2. **Construir el proyecto para la web**:

    ```bash
    flutter build web
    ```

3. **Desplegar en Firebase Hosting**:

    ```bash
    firebase deploy
    ```

### Despliegue en Android

1. **Construir el proyecto para Android**:

    ```bash
    flutter build apk
    ```

2. **Instalar el APK en un dispositivo Android**:

    ```bash
    flutter install
    ```

## Uso

### Autenticación

- **Registro de Administrador**:
  El administrador puede registrarse proporcionando un correo electrónico y una contraseña.

- **Inicio de Sesión**:
  El administrador puede iniciar sesión con sus credenciales.
  
![image](https://github.com/user-attachments/assets/dcc6f524-830c-4de0-95c9-9ece12ea308e)
  
### Gestión de Salas

- **Crear Sala**:
  El administrador puede crear una nueva sala proporcionando un nombre.

- **Eliminar Sala**:
  El administrador puede eliminar una sala existente.

- **Copiar Código de Sala**:
  El administrador puede copiar el código de la sala al portapapeles para compartirlo con otros usuarios.

![image](https://github.com/user-attachments/assets/531addc6-a47f-4b3f-a022-c6d07da4e5c3)

### Acciones dentro de la Sala

#### Administrador

- **Ver Usuarios**:
  El administrador puede ver la lista de usuarios en la sala.

- **Actualizar Órden de Usuarios**:
  El administrador puede cambiar el orden de los usuarios en la lista.

- **Activar/Desactivar Usuarios**:
  El administrador puede activar o desactivar usuarios en la sala.

- **Eliminar Usuarios**:
  El administrador puede eliminar usuarios de la sala.

- **Calcular Métricas Geográficas**:
  El administrador puede calcular el área y perímetro del polígono formado por las ubicaciones de los usuarios.
  
![image](https://github.com/user-attachments/assets/d5e62075-18d8-46e0-882b-3b6df74c565f)

#### Usuario

- **Unirse a una Sala**:
  El usuario puede unirse a una sala existente mediante el código de la sala.

- **Ubicación en Tiempo Real**:
  El usuario puede actualizar su ubicación en tiempo real dentro de la sala.

![image](https://github.com/user-attachments/assets/91678bbf-2855-4374-87d4-5fa1e0630bdd)

![image](https://github.com/user-attachments/assets/81c921f4-1859-4173-8b72-ec637fc5146f)


### Métricas Geográficas

- El administrador y usuarios pueden calcular el área y perímetro de un polígono formado por las ubicaciones de los usuarios en la sala.
  
![image](https://github.com/user-attachments/assets/b2586183-7a24-44fe-acbf-c75d02ac2d4e)

## Autores

- **Jhordy Aguas** - [Jhordy1-1/](https://github.com/Jhordy1-1)
