import QtQuick 2.0
import Bacon2D 1.0

Game {
    id: root

    property int currentLevel: 0
    property int bigFontSize: root.width / 15.0

    width: 800
    height: 600

    currentScene: levelCompletedScene

    FontLoader { id: dPuntillasFont; source: "fonts/d-puntillas-D-to-tiptoe.ttf" }

    Scene {
        id: levelCompletedScene
        anchors.fill: parent

        Rectangle {
            color: "black"
            anchors.fill: parent
        }

        Column {
            anchors.centerIn: parent
            Text {
                id: levelCompletedText
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.family: dPuntillasFont.name
                font.pointSize: root.bigFontSize
                visible: root.currentLevel > 0
                text: "Level " + root.currentLevel + " completed!"
            }

            Text {
                id: startNextText
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.family: dPuntillasFont.name
                font.pointSize: root.bigFontSize

                text: root.currentLevel > 0 ? "Next Level" : "Start"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentLevel++;
                        gameScene._reset();
                        root.currentScene = gameScene;
                    }
                }
            }

        }
    }

    Scene {
        id: gameOverScene
        anchors.fill: parent

        Rectangle {
            color: "black"
            anchors.fill: parent
        }

        Column {
            Text {
                id: gameOverText

                color: "white"

                font.family: dPuntillasFont.name
                font.pointSize: root.bigFontSize

                anchors.horizontalCenter: parent.horizontalCenter

                text: "Game over!"
            }

            Text {
                color: "white"

                font.family: dPuntillasFont.name
                font.pointSize: root.bigFontSize

                anchors.horizontalCenter: parent.horizontalCenter

                text: "Game over!"
            }
        }
    }

 
    Scene {
        id: gameScene
        anchors.fill: parent

        focus: true

        debug: false

        gravity: Qt.point(0, 0)

        property int numberOfAsteroids: 3 + Math.floor(root.currentLevel * 0.5)
        property int totalAsteroids: 0
        property bool isUpPressed: upArea.pressed
        property bool isDownPressed: downArea.pressed
        property bool isLeftPressed: false
        property bool isRightPressed: false

        Keys.onUpPressed: isUpPressed = true
        Keys.onDownPressed: isDownPressed = true
        Keys.onLeftPressed: isLeftPressed = true
        Keys.onRightPressed: isRightPressed = true
        Keys.onSpacePressed: ship.fire();

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

        onContactPostSolve: {
            var entityA = contact.fixtureA.entity
            var entityB = contact.fixtureB.entity

            if (entityA.objectName === "asteroid" || entityB.objectName === "asteroid") {
                var asteroidObject
                if (entityA.objectName === "bullet" || entityB.objectName === "bullet") {
                    var bulletObject;
                    if (entityA.objectName === "bullet") {
                        asteroidObject = entityB;
                        bulletObject = entityA;
                    } else {
                        asteroidObject = entityA;
                        bulletObject = entityB;
                    }

                    bulletObject.destroy();
                    asteroidObject.damage();
                }
            }

            console.log(entityA.objectName, entityB.objectName)
        }

        onTotalAsteroidsChanged: {
            console.log("Total asteroids:", gameScene.totalAsteroids)
            if (gameScene.totalAsteroids == 0)
                game.currentScene = levelCompletedScene
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

        MouseArea {
            anchors.fill: background
            onClicked: ship.fire();
        }

        ScriptBehavior {
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

        ScriptBehavior {
            id: shipBehavior

            script: {
                keepInsideViewBehavior.keepInsideView(entity)

                if (gameScene.isUpPressed || gameScene.isDownPressed) {
                    var heading = Qt.point(gameScene.isUpPressed ? 10 : -10, 0);
                    var angle = entity.rotation * Math.PI / 180.0;
                    var rotatedHeading = gameScene.rotatePoint(heading, angle);

                    entity.applyLinearImpulse(rotatedHeading, entity.center);
                }

                if (gameScene.isLeftPressed || gameScene.isRightPressed) {
                    var rotationSpeed = gameScene.isRightPressed ? -1 : 1;
                    entity.setAngularVelocity(rotationSpeed);
                } else if (!gameScene.isLeftPressed && !gameScene.isRightPressed)
                    entity.setAngularVelocity(0);
            }
        }

        Component {
            id: bulletComponent

            Entity {
                id: bullet

                property point center: Qt.point(x + width / 2, y + height / 2)

                objectName: "bullet"

                width: 5
                height: 5

                entityType: Bacon2D.DynamicType

                behavior: keepInsideViewBehavior

                Fixture {
                    anchors.fill: parent

                    material: Material {
                        friction: 0.3
                        density: 3
                        restitution: 0.5
                    }

                    shape: Circle {
                        anchors.fill: parent
                        fill: ColorFill {
                            brushColor: "yellow"
                        }
                    }
                }

                Timer {
                    running: true
                    interval: 1000
                    triggeredOnStart: false
                    repeat: false

                    onTriggered: bullet.destroy()
                }
            }
        }

        Entity {
            id: ship

            objectName: "ship"

            width: shipSprite.width
            height: shipSprite.height
            x: gameScene.width / 2.0 - ship.width / 2.0
            y: gameScene.height / 2.0 - ship.height / 2.0
            property point center: Qt.point(x + width / 2, y + height / 2)
            entityType: Bacon2D.DynamicType
            rotation: knob.rotation

            behavior: shipBehavior

            Fixture {
                anchors.fill: parent
                material: shipMaterial

                shape: Box {
                    anchors.fill: parent
                }
            }

            Material {
                id: shipMaterial

                friction: 0.3
                density: 3
                restitution: 0.5
            }

            Sprite {
                id: shipSprite
                animation: "thrusting"

                animations: [
                    SpriteAnimation {
                        name: "thrusting"

                        source: "images/ship_sprite.png"
                        frames: 4
                        duration: gameScene.isUpPressed ? 200 : 500
                        loops: Animation.Infinite
                    }
                ]
            }

            function fire() {
                var originPoint = Qt.point(ship.width / 2.0 + 5, 0);

                var angle = ship.rotation * Math.PI / 180.0;
                var rotatedOrigin = gameScene.rotatePoint(originPoint, angle);

                console.log(rotatedOrigin.x, rotatedOrigin.y)

                var bulletObject = bulletComponent.createObject(gameScene);
                bulletObject.x = ship.center.x + rotatedOrigin.x
                bulletObject.y = ship.center.y + rotatedOrigin.y

                bulletObject.applyLinearImpulse(rotatedOrigin, bulletObject.center)
            }
        }


        Component {
            id: asteroidSpriteComponentL1

            Asteroid {
                id: asteroid

                maxImpulse: 1000
                maxAngularVelocity: 0.1

                splitLevel: 1
                childAsteroid: asteroidSpriteComponentL2
                behavior: keepInsideViewBehavior
                onAsteroidCreated: gameScene.totalAsteroids += 1
                onAsteroidDestroyed: gameScene.totalAsteroids -= 1
            }
        }

        Component {
            id: asteroidSpriteComponentL2

            Asteroid {
                id: asteroid

                maxImpulse: 400
                maxAngularVelocity: 0.1

                splitLevel: 2
                childAsteroid: asteroidSpriteComponentL3
                behavior: keepInsideViewBehavior
                onAsteroidCreated: gameScene.totalAsteroids += 1
                onAsteroidDestroyed: gameScene.totalAsteroids -= 1
            }
        }

        Component {
            id: asteroidSpriteComponentL3

            Asteroid {
                id: asteroid

                maxImpulse: 100
                maxAngularVelocity: 0.1

                splitLevel: 3
                behavior: keepInsideViewBehavior
                onAsteroidCreated: gameScene.totalAsteroids += 1
                onAsteroidDestroyed: gameScene.totalAsteroids -= 1
            }
        }

        Knob {
            id: knob
            z: 1
            anchors.bottom: parent.bottom
            width: parent.width >= 800 ? 200 : parent.width/2
            height: width
        }

        Column {
            id: thrustArea
            z: 1
            anchors {
                bottom: parent.bottom
                right: parent.right
                bottomMargin: 10
                rightMargin: 10
            }
            height: (width * 2) + spacing
            width: parent.width >= 800 ? 100 : parent.width/3
            spacing: 10
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: parent.width
                color: "white"
                opacity: 0.1
                MouseArea {
                    id: upArea
                    anchors.fill: parent
                }
            }
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: parent.width
                color: "white"
                opacity: 0.1
                MouseArea {
                    id: downArea
                    anchors.fill: parent
                }
            }
        }

        function rotatePoint(point, angle) {
            var rotatedPoint = Qt.point((point.x * Math.cos(angle)) - (point.y * Math.sin(angle)),
                                        (point.x * Math.sin(angle)) + (point.y * Math.cos(angle)));

            return rotatedPoint;
        }

        function _reset() {
            var asteroidObject;

            for (var i = 0; i < gameScene.numberOfAsteroids; i++) {
                asteroidObject = asteroidSpriteComponentL1.createObject(gameScene);
                asteroidObject.x = Math.random() * gameScene.width;
                asteroidObject.y = Math.random() * gameScene.height;
            }
        }
    }
}
