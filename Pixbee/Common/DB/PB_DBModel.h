//
//  PB_DBModel.h
//  Pixbee
//
//  Created by jaecheol kim on 12/1/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface PB_FaceData : NSObject
//
//@property (nonatomic, strong) NSNumber *index;
//@property (nonatomic, strong) NSString *UserID;
// 
//@end
//
//
//@interface PB_album : NSObject
//
//@property (nonatomic, strong) NSNumber * index;
//@property (nonatomic, strong) NSString * album_contents;
//@property (nonatomic, strong) NSString * album_date;
//@property (nonatomic, strong) NSString * album_id;
//@property (nonatomic, strong) NSString * album_name;
//@property (nonatomic, strong) NSString * album_title;
//@property (nonatomic, strong) NSString * album_update_date;
//
//@end
//
//@interface PB_exif : NSObject
//@property (nonatomic, strong) NSNumber * exif_aperture;
//@property (nonatomic, strong) NSNumber * exif_exposuretime;
//@property (nonatomic, strong) NSNumber * exif_flash;
//@property (nonatomic, strong) NSNumber * exif_fnumber;
//@property (nonatomic, strong) NSNumber * exif_focallength;
//@property (nonatomic, strong) NSNumber * exif_height;
//@property (nonatomic, strong) NSNumber * exif_ISO;
//@property (nonatomic, strong) NSNumber * exif_latitude;
//@property (nonatomic, strong) NSString * exif_latitudeRef;
//@property (nonatomic, strong) NSNumber * exif_longitude;
//@property (nonatomic, strong) NSString * exif_longitudeRef;
//@property (nonatomic, strong) NSNumber * exif_meteringmode;
//@property (nonatomic, strong) NSNumber * exif_orientation;
//@property (nonatomic, strong) NSString * exif_programname;
//@property (nonatomic, strong) NSNumber * exif_shutterspeed;
//@property (nonatomic, strong) NSNumber * exif_subjectdistance;
//@property (nonatomic, strong) NSNumber * exif_whitebalance;
//@property (nonatomic, strong) NSNumber * exif_width;
//@property (nonatomic, strong) NSNumber * exif_xresolution;
//@property (nonatomic, strong) NSNumber * exif_yresolution;
//@end
//
//
//@interface PB_photos : NSObject
//
//@property (nonatomic, strong) NSNumber * index;
//@property (nonatomic, strong) NSString * album_type;
//@property (nonatomic, strong) NSString * album_id;
//@property (nonatomic, strong) NSString * photo_date;
//@property (nonatomic, strong) NSString * photo_id;
//@property (nonatomic, strong) NSString * photo_latitude;
//@property (nonatomic, strong) NSString * photo_longitude;
//@property (nonatomic, strong) NSString * photo_make;
//@property (nonatomic, strong) NSString * photo_model;
//@property (nonatomic, strong) NSString * photo_persontype;
//@property (nonatomic, strong) NSString * photo_place;
//@property (nonatomic, strong) NSString * photo_source;
//@property (nonatomic, strong) NSString * photo_title;
//@property (nonatomic) BOOL photo_selfcamera;
//@property (nonatomic) BOOL photo_best;
//@property (nonatomic, strong) NSDictionary * photo_edit_info;
//@property (nonatomic, strong) NSNumber * photo_file_size;
//
//@property (nonatomic, strong) PB_exif *exif;
//
//@end

/*
NSString *TraininhDB = @"training-data.sqlite";

const char *peopleSQL = "CREATE TABLE IF NOT EXISTS people ("
"'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
"'name' text NOT NULL)";
const char *newPersonSQL = "INSERT INTO people (name) VALUES (?)";
const char *findPeopleSQL = "SELECT id, name FROM people ORDER BY name";
const char* selectSQL = "SELECT name FROM people WHERE id = ?";

const char *imagesSQL = "CREATE TABLE IF NOT EXISTS images ("
"'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
"'person_id' integer NOT NULL, "
"'image' blob NOT NULL)";
const char* selectSQL = "SELECT person_id, image FROM images";
const char* deleteSQL = "DELETE FROM images WHERE person_id = ?";
const char* selectSQL = "SELECT COUNT(*) FROM images WHERE person_id = ?";
const char* insertSQL = "INSERT INTO images (person_id, image) VALUES (?, ?)";


User_data
------------------
User_id
User_name
User_profile_url
fb_id
fb_name
fb_profile_url
People_id
People_name


Album_data
------------------
Album_id
Album_name
User_id
photo_count
display_order


Album_List
------------------
Album_id
User_id


Photo_data
------------------
Photo_id
 
 */




