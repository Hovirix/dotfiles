import QtQuick
import Quickshell.Services.Notifications

Item {
    id: root

    property var items: []

    function remove(notification) {
        items = items.filter(function(item) { return item !== notification })
    }

    NotificationServer {
        actionsSupported: false
        bodySupported: true
        imageSupported: true
        persistenceSupported: false
        keepOnReload: false

        onNotification: function(notification) {
            notification.tracked = true
            root.items = [notification].concat(root.items.filter(function(item) {
                return item !== notification
            }))

            while (root.items.length > 5) {
                var oldest = root.items[root.items.length - 1]
                root.items = root.items.slice(0, root.items.length - 1)
                oldest.expire()
            }
        }
    }
}
