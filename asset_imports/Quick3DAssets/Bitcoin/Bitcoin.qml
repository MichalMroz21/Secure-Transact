import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources

    // Nodes:
    Node {
        id: bitcoin_obj
        objectName: "bitcoin.obj"
        Model {
            id: curve
            objectName: "Curve"
            source: "meshes/curve_mesh.mesh"
            materials: [
                svgmat_material
            ]
        }
        Model {
            id: logo
            objectName: "LOGO"
            source: "meshes/logo_mesh.mesh"
            materials: [
                gold_material,
                gold_001_material,
                gold_002_material
            ]
        }
        Model {
            id: curve_002
            objectName: "Curve.002"
            source: "meshes/curve_002_mesh.mesh"
            materials: [
                material_004_material
            ]
        }
        Model {
            id: curve_004
            objectName: "Curve.004"
            source: "meshes/curve_004_mesh.mesh"
            materials: [
                gold_material
            ]
        }
    }

    Node {
        id: __materialLibrary__

        PrincipledMaterial {
            id: svgmat_material
            objectName: "SVGMat"
            baseColor: "#ff000000"
            indexOfRefraction: 1
        }

        PrincipledMaterial {
            id: gold_material
            objectName: "GOLD"
            baseColor: "#ffcccccc"
            indexOfRefraction: 1.4500000476837158
        }

        PrincipledMaterial {
            id: gold_001_material
            objectName: "GOLD.001"
            baseColor: "#ffcccccc"
            indexOfRefraction: 1.4500000476837158
        }

        PrincipledMaterial {
            id: gold_002_material
            objectName: "GOLD.002"
            baseColor: "#ffcccccc"
            indexOfRefraction: 1.4500000476837158
        }

        PrincipledMaterial {
            id: material_004_material
            objectName: "Material.004"
            baseColor: "#ff030303"
            indexOfRefraction: 1.4500000476837158
        }
    }

    // Animations:
}
