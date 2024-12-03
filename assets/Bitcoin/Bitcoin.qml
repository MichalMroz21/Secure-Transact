import QtQuick
import QtQuick3D

import "../../source_gui/app_style"

Node {
    id: node

    ColorPalette { id: colorPalette }

    // Resources
    PrincipledMaterial {
        id: svgmat_material
        objectName: "SVGMat"
        baseColor: colorPalette.generic100  // Change to green
        indexOfRefraction: 1
    }

    PrincipledMaterial {
        id: gold_material
        objectName: "GOLD"
        baseColor: colorPalette.primary600
        indexOfRefraction: 1.4500000476837158
    }

    PrincipledMaterial {
        id: gold_001_material
        objectName: "GOLD.001"
        baseColor: colorPalette.primary400
        indexOfRefraction: 1.4500000476837158
    }

    PrincipledMaterial {
        id: gold_002_material
        objectName: "GOLD.002"
        baseColor: colorPalette.generic100
        indexOfRefraction: 1.4500000476837158
    }

    PrincipledMaterial {
        id: material_004_material
        objectName: "Material.004"
        baseColor: "#ff030303"
        indexOfRefraction: 1.4500000476837158
    }

    // Nodes:
    Node {
        id: bitcoin_obj
        objectName: "bitcoin.obj"
        Model {
            id: curve
            objectName: "Curve"
            source: "meshes/curve_mesh.mesh"
            materials: [
                svgmat_material  // Apply the updated green material here
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
    // Animations:
}
