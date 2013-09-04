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

        focus: true

        debug: true

        anchors.fill: parent

        gravity: Qt.point(0, 0)

        property int numberOfAsteroids: 3 + Math.floor(root.currentLevel * 0.5)
        property bool isUpPressed: false
        property bool isDownPressed: false
        property bool isLeftPressed: false
        property bool isRightPressed: false

        Keys.onUpPressed: isUpPressed = true
        Keys.onDownPressed: isDownPressed = true
        Keys.onLeftPressed: isLeftPressed = true
        Keys.onRightPressed: isRightPressed = true

        Keys.onReleased: {
            switch (event.key) {
            case Qt.Key_Up:
                isUpPressed = false
                break
            case Qt.Key_Down:
                isDownPressed = false
                break
            case Qt.Key_Left:
                isLeftPressed = false
                break
            case Qt.Key_Right:
                isRightPressed = false
                break
            }
        }

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

        QuasiScriptBehavior {
            id: keepInsideViewBehavior

            script: {
                keepInsideView(entity);
            }

            function keepInsideView(entity) {
                // vertical swap
                if ((entity.y + entity.height) < 0)
                    entity.y = gameScene.height;
                if (entity.y > gameScene.height)
                    entity.y = -entity.height;

                // horizontal swap
                if (entity.x > gameScene.width)
                    entity.x = -entity.width
                if ((entity.x + entity.width) < 0)
                    entity.x = gameScene.width
            }
        }

        QuasiScriptBehavior {
            id: shipBehavior

            script: {
                keepInsideViewBehavior.keepInsideView(entity)

                if (gameScene.isUpPressed || gameScene.isDownPressed) {
                    var heading = Qt.point(gameScene.isUpPressed ? 10 : -10, 0);
                    var angle = entity.rotation * Math.PI / 180.0;

                    var rotatedHeading = Qt.point((heading.x * Math.cos(angle)) - (heading.y * Math.sin(angle)),
                                                  (heading.x * Math.sin(angle)) + (heading.y * Math.cos(angle)));

                    console.log(entity.center.x, entity.center.y, rotatedHeading.x, rotatedHeading.y);
                    entity.applyLinearImpulse(rotatedHeading, entity.center);
                }
            }
        }

        QuasiEntity {
            id: ship

            width: shipSprite.width
            height: shipSprite.height
            x: gameScene.width / 2.0 - ship.width / 2.0
            y: gameScene.height / 2.0 - ship.height / 2.0
            property variant center: Qt.point(x + width / 2, y + height / 2)

            entityType: Quasi.DynamicType

            behavior: shipBehavior

            QuasiFixture {
                anchors.fill: parent
                material: shipMaterial
                shape: QuasiRectangle {
                    anchors.fill: parent
                }
            }

            QuasiMaterial {
                id: shipMaterial

                friction: 0.3
                density: 3
                restitution: 0.5
            }

            QuasiSprite {
                id: shipSprite

                animation: "thrusting"

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

                behavior: keepInsideViewBehavior
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
