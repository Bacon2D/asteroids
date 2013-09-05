import QtQuick 1.1
import QuasiGame 1.0

QuasiEntity {
    id: asteroid

    objectName: "asteroid"

    property variant center: Qt.point(x + width / 2, y + height / 2)
    property double maxImpulse: 1000
    property double maxAngularVelocity: 0.1
    property int splitLevel: 1
    property variant childAsteroid

    signal asteroidCreated();
    signal asteroidDestroyed();

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
        asteroidCreated();
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

    function createChild(component)
    {
        var asteroidObject = component.createObject(gameScene);
        asteroidObject.x = asteroid.x + Math.random() * asteroid.width;
        asteroidObject.y = asteroid.y + Math.random() * asteroid.height;
    }

    function createChildren(component) {
        createChild(component);
        createChild(component);
        asteroidDestroyed();
        asteroid.destroy();
    }

    function damage() {
        explosionAnimation.visible = true;
        explosionAnimation.initializeAnimation();
        explodeTimer.start();
    }

    Timer {
        id: explodeTimer

        interval: 400
        running: false
        onTriggered: {
            if (asteroid.childAsteroid != undefined)
                createChildren(asteroid.childAsteroid)
            asteroid.destroy();
        }
    }
}
