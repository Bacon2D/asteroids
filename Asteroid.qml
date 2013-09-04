import QtQuick 1.1
import QuasiGame 1.0

QuasiEntity {
    id: asteroid

    objectName: "asteroid"

    property variant center: Qt.point(x + width / 2, y + height / 2)
    property double maxImpulse: 1000 + root.currentLevel;
    property double maxAngularVelocity: 0.1 + (root.currentLevel * 0.1);
    property int splitLevel: 1

    width: asteroidImage.width
    height: asteroidImage.height

    entityType: Quasi.DynamicType

    QuasiFixture {
        anchors.fill: parent
        material: asteroidMaterial
        shape: QuasiCircle {
            anchors.fill: parent
        }
    }

    QuasiMaterial {
        id: asteroidMaterial

        friction: 0.3
        density: 5
        restitution: 0.5
    }

    Image {
        id: asteroidImage
        source: "images/asteroid-s"+ asteroid.splitLevel + "-" + Math.ceil((Math.random() * 5) + 1) + ".png"
    }

    QuasiSprite {
        id: explosionAnimation

        visible: false

        animation: "explosion"

        anchors.centerIn: parent

        animations: QuasiSpriteAnimation {
            running: false
            name: "explosion"
            source: "images/explosion.png"
            frames: 4
            duration: 400

            onFinished: explosionAnimation.visible = false
        }
    }

    Component.onCompleted: {
        applyRandomImpulse();
        setRandomAngularVelocity();
    }

    function randomDirection() {
        return ((Math.random() >= 0.5) ? -1.0 : 1.0);
    }

    function randomImpulse() {
        return Math.random() * asteroid.maxImpulse * randomDirection();
    }

    function randomAngularVelocity() {
        return asteroid.maxAngularVelocity * randomDirection();
    }

    function applyRandomImpulse() {
        var impulse = Qt.point(randomImpulse(), randomImpulse());
        applyLinearImpulse(impulse, center);
    }

    function setRandomAngularVelocity() {
        setAngularVelocity(randomAngularVelocity());
    }

    function damage() {
        explosionAnimation.visible = true;
        explosionAnimation.initializeAnimation();
    }
}
