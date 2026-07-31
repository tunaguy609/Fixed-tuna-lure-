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

$fn = preview ? 90 : 300;


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

grooveWidth = 1.5;

grooveDepth = 1;

groove1 = 30;

groove2 = 36;


//==============================
// EYES
//==============================

eyeDiameter = 10;

eyeDepth = 2.5;

eyeLocation = 50;

eyeFlatDepth = .6;

eyeFlatDiameter = 14;


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

    // Rounded nose
    [noseDiameter / 2, 0.0],
    [3.70, 2.0],
    [3.95, 4.0],
    [4.30, 6.0],
    [4.75, 8.0],
    [5.30, 10.0],

    // Gentle forward expansion
    [5.90, 13.0],
    [6.60, 16.0],
    [7.40, 19.0],
    [8.25, 22.0],
    [9.05, 25.0],

    // Mid-body
    [9.85, 28.0],
    [10.55, 31.0],
    [11.10, 34.0],
    [11.45, 37.0],
    [11.70, 40.0],
    [11.88, 43.0],
    [11.97, 46.0],

    // Straight rear section (24 mm OD)
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
    translate([0, 0, -spigotLength])
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
        translate([0, 0, -shoulderRadius])
            cylinder(
                h = shoulderRadius,
                d1 = bodyDiameter,
                d2 = spigotDiameter
            );
    }
}

//-------------------------------------------------------------
// Rounded collar
//-------------------------------------------------------------
module retaining_collar(zPos)
{
    translate([0, 0, zPos])
        minkowski()
        {
            difference()
            {
                cylinder(
                    h = collarWidth - (collarHeight / 2),
                    d = spigotDiameter + (2 * collarHeight)
                );

                translate([0, 0, -0.1])
                    cylinder(
                        h = collarWidth,
                        d = spigotDiameter
                    );
            }

            sphere(r = collarHeight / 2);
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
                -spigotLength
                + collarOffset
            );

            // Collar #2
            retaining_collar(
                -spigotLength
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
    translate([0, 0, zPos - grooveWidth / 2])
        rotate_extrude(convexity = 10)
        translate([
            bodyDiameter / 2 - grooveDepth,
            0
        ])
        square(
            [grooveDepth, grooveWidth],
            center = false
        );
}

//-------------------------------------------------------------
// Eye pad
//-------------------------------------------------------------
module eye_pad(side = 1)
{
    translate([
        side * (bodyDiameter / 2 - eyeFlatDepth / 2),
        0,
        eyeLocation
    ])
        rotate([0, 90, 0])
        cylinder(
            d = eyeFlatDiameter,
            h = eyeFlatDepth,
            center = true
        );
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
        rotate([0, 90, 0])
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
    translate([0, 0, -spigotLength - 1])
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
    translate([0, 0, -skirtPocketDepth])
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

        if (showEyes)
        {
            eye_pad(1);
            eye_pad(-1);
        }
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
