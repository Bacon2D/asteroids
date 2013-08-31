import QtQuick 1.1
import QuasiGame 1.0

QuasiGame {
    id: root

    property int currentLevel: 1

    width: 800
    height: 600

    currentScene: gameScene

    QuasiScene {
        id: gameScene

        debug: true

        anchors.fill: parent

        gravity: Qt.point(0, 0)

        property int numberOfAsteroids: 3

        Rectangle {
            id: background

            color: "black"
            anchors.fill: parent
        }

        Component {
            id: asteroidSpriteComponent

            QuasiEntity {
                id: asteroid

                property variant center: Qt.point(x + width / 2, y + height / 2)
                property double maxImpulse: 5 + (root.currentLevel * 0.2);
                property double maxAngularVelocity: 0.1 + (root.currentLevel * 0.1);

                width: asteroidImage.width
                height: asteroidImage.height

                entityType: Quasi.DynamicType

                Image {
                    id: asteroidImage
                    source: "images/asteroid-" + Math.ceil((Math.random() * 5) + 1) + ".png"
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
            }
        }

        Component.onCompleted: {
            var spriteObject;

            for (var i = 0; i < gameScene.numberOfAsteroids; i++) {
                spriteObject = asteroidSpriteComponent.createObject(gameScene);
                spriteObject.x = Math.random() * root.width;
                spriteObject.y = Math.random() * root.height;
            }
        }
    }
}
