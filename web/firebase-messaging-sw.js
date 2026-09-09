importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
 apiKey: 'AIzaSyCjg_8pYwxzJxA65tfbJ0UAa7Jro2ndWD0',
          appId: '1:514591237973:web:c93bd7a81add98a998f1dc',
          messagingSenderId: '514591237973',
          projectId: 'swwisho-45670',
          authDomain: 'swwisho-45670.firebaseapp.com',
          databaseURL: 'https://swwisho-45670-default-rtdb.asia-southeast1.firebasedatabase.app',
          storageBucket: 'swwisho-45670.firebasestorage.app',
          measurementId: 'G-DGSH2QWB7T',
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});