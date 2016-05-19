/*
   Copyright 2015 Scott Bezek

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

use<spool.scad>;
use<publicDomainGearV1.1.scad>;
use<28byj-48.scad>;
use<projection_renderer.scad>;
use<label.scad>;
use<assert.scad>;

// ##### RENDERING OPTIONS #####

render_3d = true;

// 3d parameters:
render_enclosure = 1; // 2=opaque color; 1=translucent; 0=invisible
render_flaps = false;
render_flap_area = 0; // 0=invisible; 1=collapsed flap exclusion; 2=collapsed+extended flap exclusion
render_units = 2;
render_unit_separation = 10;

// 2d parameters:
render_index = 0;
render_etch = false;

// Version label:
render_revision = "deadbeef";
render_date = "YYYY-MM-DD";


// Kerf based off http://blog.ponoko.com/2011/07/12/figuring-out-kerf-for-precision-parts/
// It's better to underestimate (looser fit) than overestimate (no fit)
kerf_value = 0.19 - 0.01;
kerf_width = render_etch ? -kerf_value : kerf_value;

// MDF, .125in nominal
// http://www.ponoko.com/make-and-sell/show-material/64-mdf-natural
thickness = 3.2;

eps=.1;

// M4 bolts
m4_hole_diameter = 4.5;
m4_bolt_length = 12;
m4_button_head_diameter = 7.6 + .2;
m4_button_head_length = 2.2 + .2;
m4_nut_width_flats = 7 + .2;
m4_nut_width_corners = 7.66 + .4;
m4_nut_length = 3.2 + .2;

captive_nut_inset=6;


loose_rod_radius_slop = 0.2;

rod_radius = 2.5;
assembly_inner_radius = rod_radius + loose_rod_radius_slop;
rod_mount_under_radius = 0.1;


assembly_color = [.76, .60, .42];
assembly_color1 = [.882, .694, .486]; //"e1b17c";
assembly_color2 = [.682, .537, .376]; //"ae8960";
assembly_color3 = [.416, .325, .227]; //"6A533A";
assembly_color4 = [.204, .161, .114]; //"34291D";

flap_width = 54;
flap_height = 43;
flap_thickness = 30 / 1000 * 25.4; // 30 mil
flap_corner_radius = 3.1; // 2.88-3.48mm (used just for display)
flap_rendered_angle = 90;

// Amount of slop of the flap side to side between the 2 spools
flap_width_slop = 1.5;

// Amount of slop for the spool assembly side-to-side inside the enclosure
spool_width_slop = 1;


num_flaps = 52;
flap_hole_radius = 1.7; // 1.2
flap_gap = 1.2; // 1



flap_spool_outset = flap_hole_radius;
flap_pitch_radius = flap_spool_pitch_radius(num_flaps, flap_hole_radius, flap_gap); //num_flaps * (flap_hole_radius*2 + flap_gap) / (2*PI);
spool_outer_radius = flap_spool_outer_radius(num_flaps, flap_hole_radius, flap_gap, flap_spool_outset); //flap_pitch_radius + 2*flap_hole_radius;

echo(flap_pitch_radius=flap_pitch_radius);

new_strut_width = 15;
new_strut_clearance = 1.5;
motor_clearance = sqrt((flap_pitch_radius - flap_hole_radius - new_strut_clearance)*(flap_pitch_radius - flap_hole_radius - new_strut_clearance) - (new_strut_width/2)*(new_strut_width/2)) - thickness - new_strut_clearance;

required_motor_clearance = sqrt((17+8)*(17+8) + 7.5*7.5) + 1;
assert(motor_clearance >= required_motor_clearance, str("Not enough motor clearance. Required ", required_motor_clearance, " but found ", motor_clearance));
echo(motor_clearance=motor_clearance);


// Radius where flaps are expected to flap in their *most collapsed* (90 degree) state
exclusion_radius = sqrt(flap_height*flap_height + flap_pitch_radius*flap_pitch_radius);
// Radius where flaps are expected to flap in their *most extended* state
outer_exclusion_radius = flap_pitch_radius + flap_height + 2;

front_forward_offset = flap_pitch_radius + flap_thickness/2;

flap_notch = sqrt(spool_outer_radius*spool_outer_radius - flap_pitch_radius*flap_pitch_radius);
echo(flap_notch=flap_notch);


flap_pin_width = flap_hole_radius*2 - 1;

enclosure_width = spool_width_slop + thickness*3 + flap_width + flap_width_slop;
front_window_upper_base = (flap_height - flap_pin_width/2);
front_window_overhang = 3;
front_window_upper = front_window_upper_base - front_window_overhang;
front_window_lower = sqrt(outer_exclusion_radius*outer_exclusion_radius - front_forward_offset*front_forward_offset);
front_window_slop = 0;
front_window_width = spool_width_slop + flap_width + flap_width_slop + front_window_slop;
front_window_right_inset = thickness - front_window_slop/2;
enclosure_vertical_margin = 10; // gap between top/bottom of flaps and top/bottom of enclosure
enclosure_vertical_inset = thickness*1.5; // distance from top of sides to top of the top piece
enclosure_height_upper = exclusion_radius + enclosure_vertical_margin + thickness + enclosure_vertical_inset;
enclosure_height_lower = flap_pitch_radius + flap_height + enclosure_vertical_margin + thickness + enclosure_vertical_inset;
enclosure_height = enclosure_height_upper + enclosure_height_lower;

enclosure_horizontal_rear_margin = thickness*2; // gap between back of gears and back of enclosure

motor_center_y_offset = 0;
motor_center_z_offset = 0;
enclosure_length = front_forward_offset - motor_center_y_offset + 10 + enclosure_horizontal_rear_margin;


motor_mount_separation = 35; // 28byj-48 mount hole separation
motor_shaft_radius = 2.5;
motor_slop_radius = 3;
motor_bushing_radius = motor_mount_separation/2 - m4_button_head_diameter/2 - 2;

spool_strut_tab_width=new_strut_width - 4;
spool_strut_tab_outset=motor_clearance+new_strut_clearance+thickness/2;
spool_strut_width = new_strut_width;
spool_strut_length_inset = thickness*0.25;
spool_strut_length = flap_width + flap_width_slop - (2 * spool_strut_length_inset);
spool_strut_inner_length = flap_width + flap_width_slop - 2 * thickness;

spool_strut_exclusion_radius = sqrt((spool_strut_tab_outset+thickness/2)*(spool_strut_tab_outset+thickness/2) + (spool_strut_tab_width/2)*(spool_strut_tab_width/2));

spool_bushing_radius = spool_strut_tab_outset - thickness/2;

// Enclosure connector tabs: front/back
num_front_tabs = 2;
front_tab_width = (enclosure_width - 2*thickness) / (num_front_tabs*2 - 1);

num_side_tabs = 5;
side_tab_width = (enclosure_length - 2*thickness) / (num_side_tabs*2 - 1);
side_tab_width_fraction = 0.5;

enclosure_length_right = front_forward_offset + motor_clearance;//side_tab_width*5 + thickness - side_tab_width * (1-side_tab_width_fraction)/2;

backstop_bolt_vertical_offset = - (exclusion_radius + outer_exclusion_radius)/2;
backstop_bolt_forward_range = 14;

// PCB parameters
pcb_offset_radius = spool_strut_exclusion_radius + 1;
pcb_height = 48;
pcb_length = 48;
pcb_thickness = 0.8;
pcb_mount_inset_vertical = 4;
pcb_mount_inset_horizontal = 8;
pcb_mount_slot_delta = 4;
pcb_reference_horizontal = -pcb_length - pcb_offset_radius;
pcb_reference_vertical = -4;

connector_bolt_offset = 40;

echo(enclosure_height=enclosure_height);
echo(enclosure_width=enclosure_width);
echo(enclosure_length=enclosure_length);
echo(enclosure_length_right=enclosure_length_right);
echo(enclosure_length_real=enclosure_length+thickness);
echo(spool_strut_inner_length=spool_strut_inner_length);
echo(front_window_width=front_window_width);
echo(front_window_upper=front_window_upper);
echo(front_window_lower=front_window_lower);
echo(front_window_height=front_window_lower+front_window_upper);
echo(front_forward_offset=front_forward_offset);



// ##### CAPTIVE NUT NEGATIVE #####

// Centered in the x dimension
module captive_nut(bolt_diameter, bolt_length, nut_width, nut_length, nut_inset) {
    union() {
        translate([-bolt_diameter/2, 0, 0])
            square([bolt_diameter, bolt_length]);
        translate([-nut_width/2, nut_inset, 0])
            square([nut_width, nut_length]);
    }
}
module m4_captive_nut(bolt_length=m4_bolt_length) {
    captive_nut(m4_hole_diameter, bolt_length + 1, m4_nut_width_flats, m4_nut_length, captive_nut_inset);
}


// ##### Struts for bracing spool #####
module spool_strut_tab_holes() {
    for (i=[0:3]) {
        angle = 90*i;
        translate([cos(angle)*(motor_clearance+new_strut_clearance), sin(angle)*(motor_clearance+new_strut_clearance)])
            rotate([0,0,angle])
                translate([0, -spool_strut_tab_width/2])
                    square([thickness, spool_strut_tab_width]);
    }
}
module spool_strut() {
    linear_extrude(thickness, center=true) {
        union() {
            translate([spool_strut_length_inset, -spool_strut_tab_width / 2]) {
                square([spool_strut_length, spool_strut_tab_width]);
            }
            translate([thickness, -spool_strut_width / 2]) {
                square([spool_strut_inner_length, spool_strut_width]);
            }
        }
    }
}

module spool_struts() {
    for (i=[0:3]) {
        angle = 90*i;
        //color([i < 2 ? 0 : 1, i == 0 || i == 2 ? 0 : 1, 0])
        color(i % 2 == 0 ? assembly_color2 : assembly_color3)
        translate([0, sin(angle)*spool_strut_tab_outset, cos(angle)*spool_strut_tab_outset])
            rotate([-angle, 0, 0])
                spool_strut();
    }
}


module flap_spool_complete(foobar) {
    linear_extrude(thickness) {
        difference() {
            flap_spool(num_flaps, flap_hole_radius, flap_gap, assembly_inner_radius, flap_spool_outset,
                    height=0);

            spool_strut_tab_holes();
            if (foobar) {
                circle(r=motor_clearance, $fn=60);
            }
        }
    }
}

module spool_bushing() {
    linear_extrude(thickness) {
        difference() {
            circle(r=spool_bushing_radius, $fn=30);
            circle(r=assembly_inner_radius, $fn=30);
        }
    }
}

module spool_with_pulleys_assembly() {
    layer_separation = thickness;
    union() {
        flap_spool_complete(false);

/*
        // Gears on spool
        translate([0,0,layer_separation])
            spool_bushing();
        translate([0,0,layer_separation*3])
            spool_bushing();
*/
    }
}

module flap() {
    color("white")
    translate([0, -flap_pin_width/2, -flap_thickness/2])
    linear_extrude(height=flap_thickness) {
        difference() {
            union() {
                square([flap_width, flap_height - flap_corner_radius + eps]);

                // rounded corners
                hull() {
                    translate([flap_corner_radius, flap_height - flap_corner_radius])
                        circle(r=flap_corner_radius, $fn=40);
                    translate([flap_width - flap_corner_radius, flap_height - flap_corner_radius])
                        circle(r=flap_corner_radius, $fn=40);
                }
            }
            translate([-eps, flap_pin_width])
                square([eps + thickness, flap_notch]);
            translate([flap_width - thickness, flap_pin_width])
                square([eps + thickness, flap_notch]);
        }
    }
}

module translated_flap() {
    translate([0, flap_pitch_radius, 0])
    rotate([flap_rendered_angle, 0, 0])
    flap();
}



// double-flatted motor shaft of 28byj-48 motor (2D)
module motor_shaft() {
    union() {
        intersection() {
            circle(r=motor_shaft_radius-rod_mount_under_radius, $fn=50);
            square([motor_shaft_radius*2, 3], center=true);
        }
        square([motor_shaft_radius/3, motor_shaft_radius*4], center=true);
    }
}

module front_tabs_negative() {
    for (i = [0 : num_front_tabs-1]) {
        translate([thickness + (i*2+0.5) * front_tab_width, 0, 0])
            square([front_tab_width, thickness], center=true);
    }
    for (i = [0 : num_front_tabs-2]) {
        translate([thickness + (i*2+1.5) * front_tab_width, 0, 0])
            circle(r=m4_hole_diameter/2, $fn=30);
    }
}

module enclosure_front() {
    linear_extrude(height=thickness) {
        difference() {
            square([enclosure_width, enclosure_height]);

            // Viewing window cutout
            translate([front_window_right_inset, enclosure_height_lower - front_window_lower])
                square([front_window_width, front_window_lower + front_window_upper]);

            // Front lower tabs
            translate([0, thickness * 0.5 + enclosure_vertical_inset, 0])
                front_tabs_negative();

            // Front upper tabs
            translate([0, enclosure_height - thickness * 0.5 - enclosure_vertical_inset, 0])
                front_tabs_negative();
        }
    }
}

module rod_mount_negative() {
    union() {
        circle(r=rod_radius - rod_mount_under_radius, center=true, $fn=30);
        square([rod_radius*4, rod_radius/3], center=true);
        square([rod_radius/3, rod_radius*4], center=true);
    }
}


// holes for 28byj-48 motor, centered around motor shaft
module motor_mount() {
    motor_mount_hole_radius = m4_hole_diameter/2;
    circle(r=motor_shaft_radius+motor_slop_radius, center=true, $fn=30);
    translate([-motor_mount_separation/2, -8])
        circle(r=motor_mount_hole_radius, center=true, $fn=30);
    translate([motor_mount_separation/2, -8])
        circle(r=motor_mount_hole_radius, center=true, $fn=30);
}

module side_tabs_negative(hole_sizes=[], extend_last_tab=false) {
    for (i = [0 : len(hole_sizes)]) {
        length = (extend_last_tab && i == len(hole_sizes)) ? side_tab_width * side_tab_width_fraction + eps : side_tab_width * side_tab_width_fraction;
        translate([-thickness / 2, thickness + (i*2) * side_tab_width + side_tab_width * (1 - side_tab_width_fraction)/2, 0])
            square([thickness, length]);
    }
    for (i = [0 : len(hole_sizes) - 1]) {
        hole_size = hole_sizes[i];
        if (hole_size > 0) {
            bolt_head_hole = hole_size == 2;
            translate([0, thickness + (i*2 + 1.5) * side_tab_width, 0])
                circle(r=(bolt_head_hole ? m4_button_head_diameter : m4_hole_diameter)/2, $fn=30);
        }
    }
}

module backstop_bolt_slot(radius) {
    hull() {
        circle(r=radius, $fn=15);
        translate([0, backstop_bolt_forward_range]) {
            circle(r=radius, $fn=15);
        }
    }
}

module enclosure_left() {
    linear_extrude(height=thickness) {
        difference() {
            square([enclosure_height, enclosure_length]);
            translate([enclosure_height_lower, enclosure_length - front_forward_offset, 0])
                rod_mount_negative();

            // idler bolt hole
            translate([enclosure_height_lower + idler_center_z_offset, enclosure_length - front_forward_offset + idler_center_y_offset])
                circle(r=idler_shaft_radius, center=true, $fn=30);

            translate([enclosure_height_lower + motor_center_z_offset, enclosure_length - front_forward_offset + motor_center_y_offset])
                motor_mount();

            // adjacent backstop bolt slot
            translate([enclosure_height_lower + backstop_bolt_vertical_offset, enclosure_length - front_forward_offset, 0]) {
                backstop_bolt_slot(radius = m4_button_head_diameter/2);
            }

            // bottom side tabs
            translate([thickness * 0.5 + enclosure_vertical_inset, 0, 0])
                side_tabs_negative(hole_sizes=[1, 0, 1, 2]);

            // top side tabs
            translate([enclosure_height - thickness * 0.5 - enclosure_vertical_inset, enclosure_length, 0])
                mirror([0, 1, 0])
                    side_tabs_negative(hole_sizes=[1,2]);

            // PCB mounting holes
            translate([enclosure_height_lower + pcb_reference_vertical, enclosure_length - front_forward_offset + pcb_reference_horizontal]) {
                pcb_mounting_holes(slots = true);
            }

            // Adjacent unit connector
            translate([enclosure_height_lower + connector_bolt_offset, enclosure_length - front_forward_offset]) {
                circle(r=m4_hole_diameter/2, $fn=15);
            }
            translate([enclosure_height_lower - connector_bolt_offset, enclosure_length - front_forward_offset]) {
                circle(r=m4_hole_diameter/2, $fn=15);
            }
        }
    }
}

module shaft_centered_motor_hole() {
    margin = 5;
    width = motor_mount_separation + 3.5*2 + margin*2;
    length = 18 + 14 + margin*2;

    translate([-width/2, -(margin + 18 + 8)])
        square([width, length]);
}

module spool_rest_bolt_holes() {
    spool_rest_slot_margin = m4_nut_width_corners - m4_nut_width_flats + 1;
    module bolt_slot() {
        hull() {
            translate([motor_clearance - m4_nut_width_corners + spool_rest_slot_margin, 0]) {
                circle(r=m4_hole_diameter/2, $fn=15);
            }
            translate([motor_clearance - m4_nut_width_corners - spool_rest_slot_margin, 0]) {
                circle(r=m4_hole_diameter/2, $fn=15);
            }
        }
    }
    union() {
        rotate([0, 0, 90]){
            bolt_slot();
        }
        rotate([0, 0, 210]){
            bolt_slot();
        }
        rotate([0, 0, -30]){
            bolt_slot();
        }
    }
}

module enclosure_right() {
    linear_extrude(height=thickness) {
        difference() {
            square([enclosure_height, enclosure_length_right]);
            translate([enclosure_height_upper, enclosure_length_right - front_forward_offset, 0])
                rod_mount_negative();

            // backstop bolt slot
            translate([enclosure_height_upper - backstop_bolt_vertical_offset, enclosure_length_right - front_forward_offset, 0]) {
                backstop_bolt_slot(radius = m4_hole_diameter/2);
            }

            // top side tabs
            translate([0.5*thickness + enclosure_vertical_inset, enclosure_length_right, 0])
                mirror([0, 1, 0])
                    side_tabs_negative(hole_sizes=[2,1], extend_last_tab=true);

            // bottom side tabs
            translate([enclosure_height - 0.5*thickness - enclosure_vertical_inset, enclosure_length_right, 0])
                mirror([0, 1, 0])
                    side_tabs_negative(hole_sizes=[1,2], extend_last_tab=true);

            // Adjacent unit connector
            translate([enclosure_height_upper - connector_bolt_offset, enclosure_length_right - front_forward_offset]) {
                circle(r=m4_hole_diameter/2, $fn=15);
            }
            translate([enclosure_height_upper + connector_bolt_offset, enclosure_length_right - front_forward_offset]) {
                circle(r=m4_hole_diameter/2, $fn=15);
            }

            // Spool rest bolts
            translate([enclosure_height_upper, enclosure_length_right - front_forward_offset]) {
                spool_rest_bolt_holes();
            }
        }
    }
}

module front_back_tabs() {
    for (i = [0 : 2 : num_front_tabs*2-2]) {
        translate([i * front_tab_width, -eps, 0])
            square([front_tab_width, thickness + eps]);
    }
}

module side_tabs(tabs) {
    for (i = [0 : 2 : tabs*2-2]) {
        translate([-eps, i * side_tab_width + side_tab_width * (1 - side_tab_width_fraction)/2, 0])
            square([thickness + eps, side_tab_width * side_tab_width_fraction]);
    }
}

module front_back_captive_nuts() {
    for (i = [0 : 2 : num_front_tabs-1]) {
        translate([(i*2 + 1.5) * front_tab_width, -thickness, 0])
            m4_captive_nut();
    }
}

module side_captive_nuts(hole_types=[]) {
    for (i = [0 : len(hole_types)-1]) {
        hole_type = hole_types[i];
        translate([-thickness, (i*2 + 1.5) * side_tab_width, 0]) {
            rotate([0, 0, -90]) {
                if (hole_type == 2) {
                    translate([-m4_button_head_diameter/2, 0])
                        square([m4_button_head_diameter, m4_button_head_length]);
                } else if (hole_type == 1) {
                    m4_captive_nut();
                }
            }
        }
    }
}


module enclosure_top() {
    // note, this is flipped upside down (around the x axis) when assembled so the clean side faces out
    linear_extrude(height = thickness) {
        difference() {
            union() {
                square([enclosure_width - 2 * thickness, enclosure_length_right]);

                // front tabs
                mirror([0, 1, 0])
                    front_back_tabs();

                // left tabs
                translate([enclosure_width - 2 * thickness, thickness, 0])
                    side_tabs(3);

                // right tabs
                mirror([1, 0, 0])
                    translate([0, thickness, 0])
                        side_tabs(3);
            }

            // front captive nuts
            front_back_captive_nuts();

            // right captive nuts
            translate([0, thickness, 0])
                side_captive_nuts(hole_types = [2,1]);

            // left captive nuts
            translate([enclosure_width - 2 * thickness, thickness, 0])
                mirror([1, 0, 0])
                    side_captive_nuts(hole_types = [1,2]);
        }
    }
}

module enclosure_bottom() {
    linear_extrude(height = thickness) {
        difference() {
            union() {
                square([enclosure_width - 2 * thickness, enclosure_length]);

                // front tabs
                translate([0, enclosure_length, 0])
                    front_back_tabs();

                // left tabs
                translate([enclosure_width - 2 * thickness, enclosure_length - thickness, 0])
                    mirror([0, 1, 0])
                        side_tabs(5);

                // right tabs
                translate([0, enclosure_length - thickness, 0])
                    mirror([0, 1, 0])
                        mirror([1, 0, 0])
                            side_tabs(3);
            }

            // front captive nuts
            translate([0, enclosure_length, 0])
                mirror([0,1,0])
                    front_back_captive_nuts();

            // right captive nuts
            translate([0, enclosure_length - thickness, 0])
                mirror([0, 1, 0])
                    side_captive_nuts(hole_types = [1,2]);

            // left captive nuts
            translate([enclosure_width - 2 * thickness, enclosure_length - thickness, 0])
                mirror([0, 1, 0])
                    mirror([1, 0, 0])
                        side_captive_nuts(hole_types = [2,1,0,1]);

        }
    }
}

module enclosure_bottom_etch() {
    color("black")
    linear_extrude(height=2, center=true) {
        translate([5, 12, thickness]) {
            text_label(["github.com/scottbez1/splitflap", str("rev. ", render_revision), render_date]);
        }
    }
}

module motor_bushing() {
    linear_extrude(height = thickness, center = true) {
        difference() {
            circle(r=motor_bushing_radius, $fn=30);
            motor_shaft();
        }
    }
}

module pcb_mounting_holes(slots=false) {
    module mounting_hole() {
        if (slots) {
            hull() {
                translate([-pcb_mount_slot_delta, 0]) {
                    circle(r=m4_hole_diameter/2, $fn=15);
                }
                translate([pcb_mount_slot_delta, 0]) {
                    circle(r=m4_hole_diameter/2, $fn=15);
                }
            }
        } else {
            circle(r=m4_hole_diameter/2, $fn=15);
        }
    }
    translate([pcb_mount_inset_vertical, pcb_mount_inset_horizontal]) {
        mounting_hole();
    }
    translate([pcb_height - pcb_mount_inset_vertical, pcb_mount_inset_horizontal]) {
        mounting_hole();
    }
}

module pcb() {
    color("green") {
        linear_extrude(height=pcb_thickness) {
            difference() {
                square([pcb_height, pcb_length]);
                pcb_mounting_holes(slots=false);
            }
        }
    }
}

module split_flap_3d() {
    module positioned_front() {
        translate([0, front_forward_offset + thickness, -enclosure_height_lower])
            rotate([90, 0, 0])
                enclosure_front();
    }

    module positioned_left() {
        translate([enclosure_width, -enclosure_length + front_forward_offset, -enclosure_height_lower])
            rotate([0, -90, 0])
                enclosure_left();
    }

    module positioned_right() {
        translate([0, -enclosure_length_right + front_forward_offset, enclosure_height_upper])
            rotate([0, 90, 0])
                enclosure_right();
    }

    module positioned_top() {
        translate([thickness, front_forward_offset, enclosure_height_upper - enclosure_vertical_inset])
            rotate([180, 0, 0])
                enclosure_top();
    }

    module positioned_bottom() {
        translate([thickness, front_forward_offset - enclosure_length, -enclosure_height_lower + enclosure_vertical_inset]) {
            enclosure_bottom();
            translate([0, 0, thickness]) {
                enclosure_bottom_etch();
            }
        }
    }

    module positioned_enclosure() {
        if (render_enclosure == 2) {
            color(assembly_color1)
                positioned_front();
            color(assembly_color2)
                positioned_left();
            color(assembly_color2)
                positioned_right();
            color(assembly_color3)
                positioned_top();
            color(assembly_color3)
                positioned_bottom();
        } else if (render_enclosure == 1) {
            %positioned_front();
            %positioned_left();
            %positioned_right();
            %positioned_top();
            %positioned_bottom();
        }
    }

    positioned_enclosure();

    translate([enclosure_width - thickness, pcb_reference_horizontal, pcb_reference_vertical])
        rotate([0, -90, 0])
            pcb();

    translate([spool_width_slop/2 + thickness, 0, 0]) {
        // Flap area
        if (render_flaps) {
            echo(flap_exclusion_radius=exclusion_radius);
            rotate([0, 90, 0]) {
                if (render_flap_area >= 1) {
                    translate([0, 0, thickness]) {
                        cylinder(r=exclusion_radius, h=flap_width - 2*thickness);
                    }
                }
                if (render_flap_area >= 2) {
                    translate([0, 0, thickness + (flap_width - 2*thickness)/4]) {
                        cylinder(r=outer_exclusion_radius, h=(flap_width - 2*thickness)/2);
                    }
                }
            }

            translate([flap_width_slop/2, 0, 0]) {
                // Collapsed flaps on the top
                for (i=[0:num_flaps/2-1]) {
                    rotate([360/num_flaps * i, 0, 0]) translated_flap();
                }

                for (i=[1:num_flaps/2]) {
                    angle = -360/num_flaps*i;
                    translate([0, flap_pitch_radius*cos(angle), flap_pitch_radius * sin(angle)])
                        rotate([-90, 0, 0])
                            flap();
                }
            }
        }

        spool_struts();

        // spool with gears
        color(assembly_color)
            translate([flap_width + flap_width_slop - thickness, 0, 0]) rotate([0, 90, 0]) spool_with_pulleys_assembly();
        color(assembly_color)
            rotate([0, 90, 0])
                flap_spool_complete(true);
        /*
        color(assembly_color1)
            translate([-thickness, 0, 0])
                rotate([0, 90, 0])
                    spool_bushing();
        */

        // motor bushing
        color(assembly_color2)
        translate([flap_width + flap_width_slop + thickness/2, motor_center_y_offset, motor_center_z_offset])
            rotate([0, 90, 0])
                motor_bushing();

        echo(motor_pitch_radius=pitch_radius(drive_pitch, motor_teeth));

        translate([flap_width + flap_width_slop + 2*thickness + spool_width_slop/2, motor_center_y_offset, motor_center_z_offset]) {
            rotate([0, -90, 0]) {
                Stepper28BYJ48();
            }
        }
    }
}

module laser_etch() {
    if (render_etch) {
        children();
    }
}

if (render_3d) {
    for (i = [0 : render_units - 1]) {
        translate([-enclosure_width/2 + (-(render_units-1) / 2 + i)*(enclosure_width + render_unit_separation), 0, 0])
            split_flap_3d();
    }
} else {
    sp = 5;
    projection_renderer(render_index=render_index, kerf_width=kerf_width) {
        translate([0, 0])
            enclosure_left();
        translate([0, enclosure_length + kerf_width])
            enclosure_right();
        translate([0, enclosure_length + enclosure_length_right + enclosure_width + 2*kerf_width])
            rotate([0, 0, -90])
                enclosure_front();

        // Place enclosure top inside the front window
        translate([enclosure_height_lower - front_window_lower + sp + thickness, enclosure_length + kerf_width + enclosure_length_right + kerf_width + enclosure_width - front_window_right_inset - enclosure_length_right - kerf_width])
            enclosure_top();

        translate([enclosure_height + kerf_width, enclosure_width])
            rotate([0, 0, -90])
                enclosure_bottom();

        laser_etch()
            translate([enclosure_height + kerf_width, enclosure_width])
                rotate([0, 0, -90])
                    enclosure_bottom_etch();

        // Spool struts 2x2 above left/right sides
        spool_strut_y_off = enclosure_length + enclosure_length_right + enclosure_width + sp + spool_strut_width / 2;
        translate([0, spool_strut_y_off])
            spool_strut();
        translate([0, spool_strut_y_off + spool_strut_width + sp])
            spool_strut();
        translate([spool_strut_length + sp, spool_strut_y_off])
            spool_strut();
        translate([spool_strut_length + sp, spool_strut_y_off + spool_strut_width + sp])
            spool_strut();

        // Flap spools above spool struts
        flap_spool_y_off = spool_strut_y_off + spool_strut_width*1.5 + sp*2 + spool_outer_radius;
        translate([spool_outer_radius, flap_spool_y_off])
            flap_spool_complete();
        translate([spool_outer_radius*3 + sp, flap_spool_y_off])
            flap_spool_complete();

    }
}

