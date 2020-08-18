// ERGO42 SPEC
ERGO_HEIGHT     = 81.254;  // 真上から見た時の高さ（マイコン部除く） ... 公式情報
ERGO_WIDTH      = 138.397; // 真上から見た時の幅（マイコン除く） ... 公式情報
PROMICRO_HEIGHT = 23;      // マイコン部の高さ ... 実測
PROMICRO_WIDTH  = 85;      // マイコン部の幅 ... 実測

// CONFIGURATIONS
PLATE_THICKNESS             = 2;  // アクリル板の厚み
ERGO_STANDOFF_THICKNESS     = 5;  // アクリル板間のスペーサの高さ（キーボード部）
PROMICRO_STANDOFF_THICKNESS = 15; // アクリル板間のスペーサの高さ（マイコン部）
OFFSET_H                    = 6;  // 外側より内側をどれだけ高くするか
OFFSET_V                    = 3;  // 手前より奥をどれだけ高くするか
WALL_THICKNESS              = 3;  // 壁の厚さ
BOTTOM_THICKNESS            = 2;  // 底の厚さ
BOTTOM_WIDTH                = 10; // 底のキーボードを支える部分の幅
BOX_THICKNESS_LIMIT         = 13; // 箱全体の最大厚さ
//BOX_THICKNESS_LIMIT         = 21; // 箱全体の最大厚さ
SCREW_AREA_WIDTH            = 7;  // ネジ頭の直径（より大きめ）
SCREW_AREA_THICKNESS        = 2;  // ネジ頭の厚さ（より大きめ）
SCREW_AREA_MARGIN_OUTER     = 7;  // マイコンの端（外側）からネジ頭までの距離（より小さめ）
SCREW_AREA_MARGIN_INNER     = 0;  // マイコンの端（内側）からネジ頭までの距離（より小さめ）

// COMPUTED CONSTANTS
ERGO_THICKNESS        = PLATE_THICKNESS * 2 + ERGO_STANDOFF_THICKNESS;
PROMICRO_THICKNESS    = PLATE_THICKNESS * 2 + PROMICRO_STANDOFF_THICKNESS;
ANGLE_X               = asin(OFFSET_H / ERGO_WIDTH);
ANGLE_Y               = asin(OFFSET_V / ERGO_HEIGHT);
THICKNESS_OFFSET_X    = ERGO_THICKNESS * sin(ANGLE_X);
THICKNESS_OFFSET_Y    = ERGO_THICKNESS * sin(ANGLE_Y);
ANGLED_ERGO_WIDTH     = ERGO_WIDTH * cos(ANGLE_X) + THICKNESS_OFFSET_X;
ANGLED_ERGO_HEIGHT    = ERGO_HEIGHT * cos(ANGLE_Y) + THICKNESS_OFFSET_Y;
ANGLED_ERGO_THICKNESS = ERGO_THICKNESS + OFFSET_H + OFFSET_V;
BOX_WIDTH             = ANGLED_ERGO_WIDTH + WALL_THICKNESS * 2;
BOX_HEIGHT            = ANGLED_ERGO_HEIGHT + WALL_THICKNESS * 2;
BOTTOM_HOLE_MARGIN    = WALL_THICKNESS + BOTTOM_WIDTH;

// -------- for previewing
pcb_thickness = 2;
module ergo42Kb () {
    key_size      = 18;
    key_thickness = 3.5;
    key_v_margin  = (ERGO_WIDTH - key_size * 7) / 8;
    key_h_margin  = (ERGO_HEIGHT - key_size * 4) / 5;
    color([0.8, 0.8, 0.8, 0.3])
        for (z = [0, PLATE_THICKNESS + ERGO_STANDOFF_THICKNESS])
            translate([0, 0, z])
                cube([ERGO_WIDTH, ERGO_HEIGHT, PLATE_THICKNESS]);
    color([0.2, 0.2, 0.2, 0.5])
        translate([0, 0, PLATE_THICKNESS + (ERGO_STANDOFF_THICKNESS - pcb_thickness) / 2])
            cube([ERGO_WIDTH, ERGO_HEIGHT, pcb_thickness]);
    color([0.4, 0.4, 0.4, 0.5])
        for (y = [0, 1, 2, 3])
            for (x = [0, 1, 2, 3, 4, 5, 6])
                translate([key_h_margin  + (key_size + key_h_margin) * x,
                           key_v_margin  + (key_size + key_v_margin) * y, ERGO_THICKNESS + 1])
                    cube([key_size, key_size, key_thickness]);
}
module ergo42Promicro () {
    sp_r          = 1;
    sp_margin     = 2;
    color([0.8, 0.8, 0.8, 0.3])
        for (z = [0, PLATE_THICKNESS + PROMICRO_STANDOFF_THICKNESS])
            translate([0, 0, z])
                cube([PROMICRO_WIDTH, PROMICRO_HEIGHT, PLATE_THICKNESS]);
    color([0.2, 0.2, 0.2, 0.5])
        translate([0, 0, PLATE_THICKNESS + (ERGO_STANDOFF_THICKNESS - pcb_thickness) / 2])
            cube([PROMICRO_WIDTH, PROMICRO_HEIGHT, pcb_thickness]);
    color([0.6, 0.6, 0.6, 0.5])
        for (y = [sp_margin + sp_r, PROMICRO_HEIGHT - sp_margin - sp_r])
            for (x = [sp_margin + sp_r, PROMICRO_WIDTH - sp_margin - sp_r])
                translate([x, y, PLATE_THICKNESS])
                    cylinder(r = sp_r, h = PROMICRO_STANDOFF_THICKNESS);
}
module ergo42R () {
    ergo42Kb();
    translate([0, ERGO_HEIGHT, 0]) ergo42Promicro();
}
module ergo42L () {
    ergo42Kb();
    translate([ERGO_WIDTH - PROMICRO_WIDTH, ERGO_HEIGHT, 0]) ergo42Promicro();
}
// --------

module tiltL () {
    translate([THICKNESS_OFFSET_X, THICKNESS_OFFSET_Y, 0])
        rotate([ANGLE_Y, -ANGLE_X, 0]) {
            children();
        }
}

module tiltR () {
    translate([ANGLED_ERGO_WIDTH - THICKNESS_OFFSET_X, THICKNESS_OFFSET_Y, 0])
        rotate([ANGLE_Y, ANGLE_X, 0])
            translate([-ERGO_WIDTH, 0, 0]) {
                children();
            }
}

module boxCube () {
    hole_width  = max(0, BOX_WIDTH - BOTTOM_HOLE_MARGIN * 2);
    hole_height = max(0, BOX_HEIGHT - BOTTOM_HOLE_MARGIN * 2);
    difference () {
        // base
        cube([BOX_WIDTH, BOX_HEIGHT, BOX_THICKNESS_LIMIT]);
        // hole of the bottom plate
        translate([BOTTOM_HOLE_MARGIN, BOTTOM_HOLE_MARGIN, -1])
            cube([hole_width, hole_height, BOX_THICKNESS_LIMIT]);
    }
}

module caseL () {
    difference () {
        boxCube();
        // ergo42
        translate([WALL_THICKNESS, WALL_THICKNESS, BOTTOM_THICKNESS]) tiltL() {
            // keyboard
            cube([ERGO_WIDTH, ERGO_HEIGHT, ERGO_THICKNESS + 1]);
            // promicro
            translate([ERGO_WIDTH - PROMICRO_WIDTH, ERGO_HEIGHT - 1, 0]) {
                cube([PROMICRO_WIDTH, PROMICRO_HEIGHT + 1, PROMICRO_THICKNESS]);
                for (x = [SCREW_AREA_MARGIN_OUTER, PROMICRO_WIDTH - SCREW_AREA_MARGIN_INNER - SCREW_AREA_WIDTH])
                    translate([x, 0, -SCREW_AREA_THICKNESS])
                        cube([SCREW_AREA_WIDTH, 100, SCREW_AREA_THICKNESS + 1]);
            }
            // upper-limit
            translate([-50, -50, ERGO_THICKNESS])
                cube([ERGO_WIDTH + 100, ERGO_HEIGHT + 100, BOX_THICKNESS_LIMIT]);
        }
    }
}

module caseR () {
    difference () {
        boxCube();
        // ergo42
        translate([WALL_THICKNESS, WALL_THICKNESS, BOTTOM_THICKNESS]) tiltR() {
            // keyboard
            cube([ERGO_WIDTH, ERGO_HEIGHT, ERGO_THICKNESS + 10]);
            // promicro
            translate([0, ERGO_HEIGHT - 1, 0]) {
                cube([PROMICRO_WIDTH, PROMICRO_HEIGHT + 1, PROMICRO_THICKNESS]);
                for (x = [SCREW_AREA_MARGIN_INNER, PROMICRO_WIDTH - SCREW_AREA_MARGIN_OUTER - SCREW_AREA_WIDTH])
                    translate([x, 0, -SCREW_AREA_THICKNESS])
                        cube([SCREW_AREA_WIDTH, 100, SCREW_AREA_THICKNESS + 1]);
            }
            // upper-limit
            translate([-50, -50, ERGO_THICKNESS])
                cube([ERGO_WIDTH + 100, ERGO_HEIGHT + 100, BOX_THICKNESS_LIMIT]);
        }
    }
}

module cheapCaseL () {
    difference () {
        caseL();
        // hole for cheaper printing
        translate([BOTTOM_HOLE_MARGIN, BOX_HEIGHT - BOTTOM_HOLE_MARGIN - 1, -1])
            cube([BOTTOM_HOLE_MARGIN + 2, BOTTOM_HOLE_MARGIN + 2, BOX_THICKNESS_LIMIT + 2]);
    }
}

module cheapCaseR () {
    difference () {
        caseR();
        // hole for cheaper printing
        translate([BOTTOM_HOLE_MARGIN, BOX_HEIGHT - BOTTOM_HOLE_MARGIN - 1, -1])
            cube([BOTTOM_HOLE_MARGIN + 2, BOTTOM_HOLE_MARGIN + 2, BOX_THICKNESS_LIMIT + 2]);
    }
}

translate([-BOX_WIDTH - 1, 0, 0]) {
    cheapCaseL();
    translate([WALL_THICKNESS, WALL_THICKNESS, BOTTOM_THICKNESS]) tiltL() ergo42L();
}
cheapCaseR();
translate([WALL_THICKNESS, WALL_THICKNESS, BOTTOM_THICKNESS]) tiltR() ergo42R();

/*
rotate([0, 0, 180])
    translate([-(BOX_WIDTH + BOTTOM_HOLE_MARGIN + 1), -(BOX_HEIGHT + BOTTOM_HOLE_MARGIN + 1), 0])
        cheapCaseL();
cheapCaseR();
*/