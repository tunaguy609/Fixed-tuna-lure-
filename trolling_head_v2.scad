///////////////////////////////////////////////////////////////
//
// HAYWIRE TACKLE
//
// Production Offshore Trolling Head
//
// Version 4.5
//
///////////////////////////////////////////////////////////////


//==============================
// QUALITY
//==============================

preview = true;

$fn = preview ? 32 : 300;


//==============================
// MAIN DIMENSIONS
//==============================

headLength = 55;

bodyDiameter = 24;

noseDiameter = 7;


//==============================
// REAR
//==============================

spigotDiameter = 19;

spigotLength = 26;

shoulderRadius = 1;


//==============================
// COLLARS
//==============================

collarWidth = 2;

collarHeight = 1;

collarSpacing = 13;

collarOffset = 9;


//==============================
// JET TUBES
//==============================

jetTubeDiameter = 2.5;

// Entry: bottom of nose at its widest point (nose taper tangent join)
jetTubeEntryZ = 12;

// Exit: top of body, angled rearward through the body like a vent slot
jetTubeExitZ = eyeLocation;


//==============================
// GROOVES
//==============================

grooveWidth = 2.5;

grooveDepth = 1.5;

groove1 = 46;

groove2 = 52;


//==============================
// EYES
//==============================

eyeDiameter = 10;

eyeDepth = 2.5;

eyeLocation = 32;


//==============================
// INTERNAL
//==============================

leaderHole = 2.5;

skirtPocketDiameter = 16;

skirtPocketDepth = 20;


//==============================
// OPTIONS
//==============================

showGrooves = true;

showEyes = true;

showCollars = true;

showLeaderHole = true;

showSkirtPocket = true;

showJetTubes = true;


///////////////////////////////////////////////////////////////
//
// BODY PROFILE
//
///////////////////////////////////////////////////////////////

// Radius profile from nose (Z=0) to rear (Z=headLength)
// Format: [radius, z]

profile = [

    // Rounded nose – circular-arc ogive, tangent to body cylinder at Z = 12 mm.
    // Arc center at (r = -0.72, z = 12), radius = 12.72 mm; gives a convex dome.
    [noseDiameter / 2,  0.0],   // face-plate edge (r = 3.5)
    [7.14,              2.0],
    [8.27,              3.0],
    [9.17,              4.0],
    [10.50,             6.0],
    [11.35,             8.0],
    [11.84,             10.0],
    [12.00,             12.0],  // tangent join to straight body

    // Straight body (24 mm OD)
    [12.00, 43.0],
    [12.00, 55.0]
];

module head_body()
{
    rotate_extrude(convexity = 20)
    polygon(
        concat(
            [[0, 0]],
            profile,
            [[0, headLength]]
        )
    );
}

///////////////////////////////////////////////////////////////
//
// SPIGOT & COLLARS
//
///////////////////////////////////////////////////////////////

//-------------------------------------------------------------
// Straight skirt spigot
//-------------------------------------------------------------
module skirt_spigot()
{
    translate([0, 0, headLength])
        cylinder(
            h = spigotLength,
            d = spigotDiameter
        );
}

//-------------------------------------------------------------
// Shoulder blend
// Creates a small 1 mm radius-like transition.
// Set shoulderRadius = 0 for a sharp shoulder.
//-------------------------------------------------------------
module shoulder_blend()
{
    if (shoulderRadius > 0)
    {
        translate([0, 0, headLength])
            cylinder(
                h = shoulderRadius,
                d1 = bodyDiameter,
                d2 = spigotDiameter
            );
    }
}

//-------------------------------------------------------------
// Rounded collar
// Uses rotate_extrude of a rounded 2D profile for performance.
//-------------------------------------------------------------
module retaining_collar(zPos)
{
    translate([0, 0, zPos])
        rotate_extrude(convexity = 10)
        hull()
        {
            translate([
                spigotDiameter / 2 + collarHeight / 2,
                collarHeight / 2
            ])
                circle(r = collarHeight / 2);

            translate([
                spigotDiameter / 2 + collarHeight / 2,
                collarWidth - collarHeight / 2
            ])
                circle(r = collarHeight / 2);
        }
}

//-------------------------------------------------------------
// Rear Assembly
//-------------------------------------------------------------
module rear_assembly()
{
    union()
    {
        head_body();

        shoulder_blend();

        skirt_spigot();

        if (showCollars)
        {
            // Collar #1
            retaining_collar(
                headLength
                + collarOffset
            );

            // Collar #2
            retaining_collar(
                headLength
                + collarOffset
                + collarWidth
                + collarSpacing
            );
        }

    }
}

///////////////////////////////////////////////////////////////
//
// MACHINED FEATURES
//
///////////////////////////////////////////////////////////////

//-------------------------------------------------------------
// Circumferential groove
//-------------------------------------------------------------
module groove(zPos)
{
    // Asymmetric cupped profile: steep forward wall to grab water,
    // flat bottom, gently ramped rear wall.
    // In 2D rotate_extrude space: X = radius, Y = axial (0 = nose side).
    translate([0, 0, zPos])
        rotate_extrude(convexity = 10)
        polygon([
            [bodyDiameter / 2,               0                    ],  // surface, forward edge
            [bodyDiameter / 2 - grooveDepth, grooveWidth * 0.2   ],  // bottom, near front
            [bodyDiameter / 2 - grooveDepth, grooveWidth * 0.75  ],  // bottom, near rear
            [bodyDiameter / 2,               grooveWidth          ]   // surface, rear edge
        ]);
}

//-------------------------------------------------------------
// Eye pocket
//-------------------------------------------------------------
module eye_pocket(side = 1)
{
    translate([
        side * (bodyDiameter / 2 + 0.01),
        0,
        eyeLocation
    ])
        rotate([0, -90 * side, 0])
        cylinder(
            d = eyeDiameter,
            h = eyeDepth
        );
}

//-------------------------------------------------------------
// Leader bore
//-------------------------------------------------------------
module leader_bore()
{
    translate([0, 0, -1])
        cylinder(
            h = headLength + spigotLength + 2,
            d = leaderHole
        );
}

//-------------------------------------------------------------
// Skirt pocket
//-------------------------------------------------------------
module skirt_pocket()
{
    translate([0, 0, headLength + spigotLength - skirtPocketDepth])
        cylinder(
            h = skirtPocketDepth + 0.1,
            d = skirtPocketDiameter
        );
}

//-------------------------------------------------------------
// Vent slot bore
// Angled bore entering at the bottom of the nose at its widest
// point (jetTubeEntryZ) and exiting through the top of the body
// rearward at jetTubeExitZ – like an upward vent slot.
// Hull of two spheres lets OpenSCAD compute the angle implicitly.
//-------------------------------------------------------------
module vent_slot_bore()
{
    hull()
    {
        // Entry: bottom of nose at its widest point – center on body surface
        translate([0, -(bodyDiameter / 2), jetTubeEntryZ])
            sphere(d = jetTubeDiameter);

        // Exit: top of body – center on body surface so full bore diameter opens
        translate([0, (bodyDiameter / 2), jetTubeExitZ])
            sphere(d = jetTubeDiameter);
    }
}

///////////////////////////////////////////////////////////////
//
// FINAL MODEL
//
///////////////////////////////////////////////////////////////

difference()
{
    union()
    {
        rear_assembly();
    }

    // Decorative grooves
    if (showGrooves)
    {
        groove(groove1);
        groove(groove2);
    }

    // Eye pockets
    if (showEyes)
    {
        eye_pocket(1);
        eye_pocket(-1);
    }

    // Internal features
    if (showLeaderHole)
        leader_bore();

    if (showSkirtPocket)
        skirt_pocket();

    // Vent slot: angled bore from nose bottom to body top
    if (showJetTubes)
    {
        vent_slot_bore();
    }
}
