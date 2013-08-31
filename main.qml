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

        property int numberOfAsteroids: 3 + Math.floor(root.currentLevel * 0.5)

        Rectangle {
            id: background

            color: "black"
            anchors.fill: parent
        }

        Image {
            id: backgroundStars

            anchors.fill: parent
            source: "images/background_stars.png"
            fillMode: Image.Tile
        }

        QuasiSprite {
            id: shipSprite

            animation: "thrusting"
            x: gameScene.width / 2.0 - shipSprite.width / 2.0
            y: gameScene.height / 2.0 - shipSprite.height / 2.0

            animations: [
                QuasiSpriteAnimation {
                    name: "thrusting"

                    source: "images/ship_sprite.png"
                    frames: 4
                    duration: 500
                    loops: Animation.Infinite
                }
            ]
        }
 

        Component {
            id: asteroidSpriteComponent

            QuasiEntity {
                id: asteroid

                property variant center: Qt.point(x + width / 2, y + height / 2)
                property double maxImpulse: 1000 + root.currentLevel;
                property double maxAngularVelocity: 0.1 + (root.currentLevel * 0.1);

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

                function keepInsideView() {
                    // vertical swap
                    if ((asteroid.y + asteroid.height) < 0)
                        asteroid.y = gameScene.height;
                    if (asteroid.y > gameScene.height)
                        asteroid.y = -asteroid.height;

                    // horizontal swap
                    if (asteroid.x > gameScene.width)
                        asteroid.x = -asteroid.width
                    if ((asteroid.x + asteroid.width) < 0)
                        asteroid.x = gameScene.width
                }

                behavior: QuasiScriptBehavior {
                    script: {
                        entity.keepInsideView();
                    }
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
