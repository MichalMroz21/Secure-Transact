import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources

    // Nodes:
    Node {
        id: scene
        objectName: "Scene"
        rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
        PointLight {
            id: point_002_light
            objectName: "Point.002"
            x: 1.9640480279922485
            y: -1.173704981803894
            z: -0.10454899817705154
            brightness: 500
            quadraticFade: 0
        }
        PointLight {
            id: point_003_light
            objectName: "Point.003"
            x: 0.001172304037027061
            y: 2.823741912841797
            z: -0.15058979392051697
            brightness: 500
            quadraticFade: 0
        }
        PointLight {
            id: point_001_light
            objectName: "Point.001"
            x: -0.014419079758226871
            y: -7.03718376159668
            z: -0.037258680909872055
            brightness: 30
            quadraticFade: 0
        }
        Model {
            id: plane_002
            objectName: "Plane.002"
            x: 3.547868013381958
            y: 3.7034189701080322
            rotation: Qt.quaternion(0.707107, 0.707107, 0, 0)
            scale.x: 9.38255
            scale.y: 5.93227
            scale.z: 9.38255
            source: "meshes/plane_006_mesh.mesh"
            materials: [
                bg_material
            ]
        }
        PerspectiveCamera {
            id: camera_camera
            objectName: "Camera"
            y: -6.419466018676758
            rotation: Qt.quaternion(0.707107, 0.707107, 0, 0)
            clipNear: 0.10000000149011612
            clipFar: 1000
            fieldOfView: 39.5977897644043
            fieldOfViewOrientation: PerspectiveCamera.Horizontal
        }
        PointLight {
            id: point_light
            objectName: "Point"
            x: -2.289595127105713
            y: -2.37998104095459
            z: -0.47561830282211304
            brightness: 500
            quadraticFade: 0
        }
        Model {
            id: plane
            objectName: "Plane"
            y: 3.7034189701080322
            rotation: Qt.quaternion(0.707107, 0.707107, 0, 0)
            scale.x: 9.38255
            scale.y: 5.93227
            scale.z: 9.38255
            source: "meshes/plane_005_mesh.mesh"
            materials: [
                bg_material
            ]
        }
        Model {
            id: plane_001
            objectName: "Plane.001"
            x: 0.026024360209703445
            y: 0.02528109960258007
            z: 0.04945391044020653
            scale.x: 0.566697
            scale.y: 0.566697
            scale.z: 0.566697
            source: "meshes/plane_003_mesh.mesh"
            materials: [
                gold_material
            ]
        }
        Model {
            id: text_001
            objectName: "Text.001"
            x: -0.0025623019319027662
            y: 0.026004299521446228
            z: 0.011283449828624725
            rotation: Qt.quaternion(0.632727, 0.632727, -0.315684, 0.315684)
            scale.x: 0.0917237
            scale.y: 0.0917237
            scale.z: 0.0917236
            source: "meshes/text_002_mesh.mesh"
            materials: [
                gold_material
            ]
        }
        Model {
            id: circle
            objectName: "Circle"
            y: 0.04832382872700691
            z: 6.397580136763281e-07
            rotation: Qt.quaternion(0.707107, 0.707107, 0, 0)
            source: "meshes/circle_mesh.mesh"
            materials: [
                gold_material,
                gold_bump_material
            ]
        }
    }

    Node {
        id: __materialLibrary__

        PrincipledMaterial {
            id: bg_material
            objectName: "BG"
            baseColor: "#ff040404"
            indexOfRefraction: 1.4500000476837158
        }

        PrincipledMaterial {
            id: gold_material
            objectName: "Gold"
            baseColor: "#ffcc6312"
            indexOfRefraction: 1.4500000476837158
        }

        PrincipledMaterial {
            id: gold_bump_material
            objectName: "Gold.bump"
            baseColor: "#ffcc6312"
            indexOfRefraction: 1.4500000476837158
        }
    }

    // Animations:
}
