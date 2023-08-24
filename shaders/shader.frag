#include<flutter/runtime_effect.glsl>

// Set high precision float calculations.
precision highp float;
// The size of the widget rectangle.
uniform vec2 uWidget;
// Pass in the texture map as a constant sampler.
uniform sampler2D uTexture;
// The visible radius.
uniform float uRadius;
// The time of day (12 hour) in terms of the s (horizontal) texture
// coordinate.
// s == 0 is the left edge of the texture, s == 1 the right edge.
uniform float uNow;
// Whether to swap blue-left/red-right with red-left/blue-right.
uniform float uSwapDayNight;
// The returned fragment colour.
out vec4 fragColor;

void main() {
    // Get texture coordinates for the screen pixel
    // in the range [0..1] on both axes.
    vec2 texCoord = FlutterFragCoord() / uWidget;

    // Look up the colour in the texture for this fragment.
    vec4 colour = texture(uTexture, texCoord);

    // s in [0..1], the x-coordinate, t in [0..1] as the y-coordinate.
    float s = texCoord.s;
    float t = texCoord.t;

    // The accumulated colour of the output fragment.
    vec4 accum = vec4(0, 0, 0, 0);

    // A fade-in value.
    float fade = clamp(uRadius, 0, 1);

    // If we are in the narrow stripe between blue and red sides, then
    // output a white pixel of increasing intensity as the radius increases.
    if (s < uNow + 0.001 && s > uNow - 0.001) {
        //        float w = (0.001 - abs(s - uNow)) * 1000.0;
        //        w = clamp(w, 0, 1);
        accum = vec4(fade, fade, fade, fade);
    }

    // Add a blend for coloured pixels near the watch hand.
    if (s < uNow + 0.004 && s > uNow - 0.004) {
        float w = (0.004 - abs(s - uNow)) * 250.0;
        accum *= vec4(w, w, w, w) * fade;
        fragColor = accum;
        return;
    }

    // If the texel (texture pixel) is black, and we are not drawing the
    // "hand" line, then we straightaway send out a black pixel to the display.
    // This immediately culls the rest of the fragment processing.
    if (colour.r == 0 && colour.g == 0 && colour.b == 0) {
        fragColor = vec4(0, 0, 0, 1);
        return;
    }

    // If the texel is grey then we send out
    // a grey pixel, for the numerals and timeline.  This brightens over
    // time.
    if (colour.r == colour.g && colour.g == colour.b) {
        fragColor = colour * fade;
        return;
    }

    // If the radius from the centre is greater than uRadius, then return black.
    float len = length(vec2((s - 0.5) * 2, (t - 0.5) * 2));

    // Adding a fudge factor based on the green colour channel makes
    // different colours expand at different rates.
    float radius2 = uRadius + colour.g * 0.3;
    if (len > radius2) {
        fragColor = vec4(0, 0, 0, 1);
        return;
    }

    if (len > uRadius) {
        float w = 1 - (len -  uRadius) / (radius2 - uRadius);
        fragColor = vec4(w, w, w, 1);
        return;
    }

    // Create a glow colour depending on the distance from the radius.
    float glow = clamp((0.3 - (uRadius - len)) * 2, 0, 0.6);

    // Set up the colours for each side.  We start with blue on
    // the left in the morning, and swap it to the right in the
    // afternoon.  This is how you tell am/pm at a glance.
    if ((s > uNow + 0.001 && uSwapDayNight <= 0.5)
    || (s < uNow - 0.001 && uSwapDayNight >= 0.5)) {
        fragColor = colour * vec4(1, 1, 0, 1) + vec4(glow, glow, glow, 1);
    } else {
        fragColor = colour * vec4(0, 1, 1, 1) + vec4(glow, glow, glow, 1);
    }
}

