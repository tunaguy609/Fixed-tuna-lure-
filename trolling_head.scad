///////////////////////////////////////////////////////////////
//
// HAYWIRE TACKLE
//
// Production Offshore Trolling Head
//
// Version 4.0
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

headLength = 65;

bodyDiameter = 24;

noseDiameter = 7;


//==============================
// REAR
//==============================

spigotDiameter = 19;

spigotLength = 22;

shoulderRadius = 1;


//==============================
// COLLARS
//==============================

collarWidth = 2;

collarHeight = 1;

collarSpacing = 10;

collarOffset = 6;


//==============================
// GROOVES
//==============================

grooveWidth = 2.5;

grooveDepth = 1.5;

grooveEdgeRadius = 0.6;

groove1 = 56;

groove2 = 62;


//==============================
// EYES
//==============================

eyeDiameter = 10;

eyeDepth = 2.5;

eyeLocation = 50;


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
    [12.00, 53.0],
    [12.00, 65.0]
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
    // Asymmetric cupped profile: steep forward wall with rolled lip to grab water,
    // flat bottom, gently ramped rear wall.  grooveEdgeRadius rounds the rim for
    // a rolled-edge cup look.
    // In 2D rotate_extrude space: X = radius, Y = axial (0 = nose side).
    translate([0, 0, zPos])
        rotate_extrude(convexity = 10)
        hull()
        {
            // Rolled forward lip
            translate([bodyDiameter / 2 - grooveEdgeRadius, grooveEdgeRadius])
                circle(r = grooveEdgeRadius);

            // Bottom, near front
            translate([bodyDiameter / 2 - grooveDepth, grooveWidth * 0.2])
                circle(r = grooveEdgeRadius * 0.3);

            // Bottom, near rear
            translate([bodyDiameter / 2 - grooveDepth, grooveWidth * 0.75])
                circle(r = grooveEdgeRadius * 0.3);

            // Rolled rear edge
            translate([bodyDiameter / 2 - grooveEdgeRadius, grooveWidth - grooveEdgeRadius])
                circle(r = grooveEdgeRadius);
        }
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
}
