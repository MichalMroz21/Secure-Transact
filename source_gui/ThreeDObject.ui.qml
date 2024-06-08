import QtQuick
import QtQuick3D

View3D {
    id: view3D
    environment: sceneEnvironment

    SceneEnvironment {
        id: sceneEnvironment
        antialiasingQuality: SceneEnvironment.High
        antialiasingMode: SceneEnvironment.MSAA
    }

    Node {
        id: scene
        DirectionalLight {
            id: directionalLight
        }

        PerspectiveCamera {
            id: sceneCamera
            x: -286.671
            y: 27.51
            z: 368.9527
        }
    }

    Item {
        id: __materialLibrary__
    }
}
