import QtQuick

// Ignore synthetic hover changes when delegates move under a stationary pointer.
QtObject {
    id: root

    property bool initialSampleAllowed: false
    property real lastX: 0
    property real lastY: 0
    property bool primed: false
    property Item referenceItem: null
    property real threshold: 1

    function allowInitialSample() {
        root.reset();
        root.initialSampleAllowed = true;
    }

    function moved(item, mouse) {
        if (!item || !mouse) {
            root.reset();
            return false;
        }
        var target = root.referenceItem || item;
        var point = item.mapToItem(target, mouse.x, mouse.y);
        var firstSample = !root.primed;
        var didMove = !firstSample ? Math.abs(point.x - root.lastX) > root.threshold || Math.abs(point.y - root.lastY) > root.threshold : root.initialSampleAllowed;
        if (firstSample || didMove) {
            root.lastX = point.x;
            root.lastY = point.y;
        }
        root.primed = true;
        root.initialSampleAllowed = false;
        return didMove;
    }

    function reset() {
        root.primed = false;
        root.initialSampleAllowed = false;
        root.lastX = 0;
        root.lastY = 0;
    }
}
