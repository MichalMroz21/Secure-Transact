import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources

    // Nodes:
    Node {
        id: etherium
        objectName: "uploads_files_993453_etherium.obj"
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

    Node {
        id: __materialLibrary__

        PrincipledMaterial {
            id: material_001_material
            objectName: "Material.001"
            baseColor: "#ffa3a3a3"
            indexOfRefraction: 1
        }
    }

    // Animations:
}
