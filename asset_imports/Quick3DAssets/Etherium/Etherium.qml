import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    PrincipledMaterial {
        id: material_001_material
        objectName: "Material.001"
        baseColor: "#ff999999"
        indexOfRefraction: 1
    }

    // Nodes:
    Node {
        id: etherium_obj
        objectName: "Etherium.obj"
        Model {
            id: circle_002
            objectName: "Circle.002"
            source: "meshes/circle_002_mesh.mesh"
            materials: [
                material_001_material
            ]
        }
        Model {
            id: circle_000
            objectName: "Circle.000"
            source: "meshes/circle_000_mesh.mesh"
            materials: [
                material_001_material
            ]
        }
    }

    // Animations:
}
