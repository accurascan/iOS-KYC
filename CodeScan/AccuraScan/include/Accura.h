#ifndef Accura_h
#define Accura_h

#include <opencv2/opencv.hpp>
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/features2d.hpp"
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/features2d/features2d.hpp>

#import <Foundation/Foundation.h>
#include <string>
#include <iostream>
#include <fstream>
#include <queue>
#include <regex>
#include <map>
#include <dirent.h>

#include <utility>
#include <algorithm>

#include "json.hpp"
#include "base64.h"


#import "encrypt.h"
#import "b64.h"


using namespace std;

typedef struct Recte {
    Recte(int i, int i1, int i2, int i3) {
        left = i;
        top = i1;
        right = i2;
        bottom = i3;
    }
    
    int left;
    int top;
    int right;
    int bottom;
    
    bool valueInRange(int value, int min, int max) { return (value >= min) && (value <= max); }
    
public:
    bool rectOverlap(Recte A, Recte B) {
        bool xOverlap = valueInRange(A.left, B.left, B.right) ||
        valueInRange(B.left, A.left, A.right);
        
        bool yOverlap = valueInRange(A.top, B.top, B.bottom) ||
        valueInRange(B.top, A.top, A.bottom);
        
        return xOverlap && yOverlap;
    }
    
    bool contains(Recte R1, Recte R2) {
        if ((R2.right) < (R1.right)
            && (R2.left) > (R1.left)
            && (R2.top) > (R1.top)
            && (R2.bottom) < (R1.bottom)
            ) {
            return true;
        } else {
            return false;
        }
    }
} RECTE, *PRECTE;

struct Data_t {
    std::string key_;
    std::string data_;
    
    Data_t(std::string key_v, std::string data_v) : key_(key_v), data_(data_v) {}
};

struct Rect_t {
    std::string key_;
    Recte data_;
    
    Rect_t(std::string key_v, Recte data_v) : key_(key_v), data_(data_v) {}
};

struct Data_Security {
    std::string key_;
    int pos_;
    Recte data_;
    
    Data_Security(std::string key_v, int pos_v, Recte data_v) : key_(key_v), pos_(pos_v),
    data_(data_v) {}
};

struct Mat_template {
    std::string key_;
    cv::Mat mat_data_;
    std::string code_;
    float similarity_;
    
    Mat_template() {}
    
    Mat_template(std::string key_v, cv::Mat data_v, std::string code_v,
                 float similarity_v) : key_(key_v),mat_data_(data_v),code_(code_v),
    similarity_(similarity_v){}
};

struct Required_t {
    std::string key_;
    int data_;
    
    
    Required_t(std::string key_v, int data_v) : key_(key_v), data_(data_v) {}
};

class MinMaxLocResult {
    
    //    MinMaxLocResult(double minval, double maxVal, const cv::Point &minLoc, const cv::Point &maxLoc)
    //            : minval(minval), maxVal(maxVal), minLoc(minLoc), maxLoc(maxLoc) {}
public:
    MinMaxLocResult(double mnV, double mxV, cv::Point mnI, cv::Point mxI) {
        minval = mnV;
        maxVal = mxV;
        minLoc = mnI;
        maxLoc = mxI;
    };
    
    bool isNull() {
        if (minval == NULL) {
            return true;
        }
        if (maxVal == NULL) {
            return true;
        }
        if ((minLoc.x == NULL) || (minLoc.y == NULL)) {
            return true;
        }
        if ((maxLoc.x == NULL) || (maxLoc.y == NULL)) {
            return true;
        }
        return false;
        
    }
    
    MinMaxLocResult() {
        minval = NULL;
        maxVal = NULL;
        minLoc.x = NULL;
        minLoc.y = NULL;
        maxLoc.x = NULL;
        maxLoc.y = NULL;
    }
    
    double maxVal;
    double minval;
    cv::Point minLoc;
    cv::Point maxLoc;
    float ratio;
};

class ImageOpenCv {
    
public:
    ImageOpenCv(const std::string &message, bool isSucess, bool isChangeCard, int cardPos,
                int resultCode, float ratioOut) : message(message), isSucess(isSucess),
    isChangeCard(isChangeCard), cardPos(cardPos),
    resultCode(resultCode), ratioOut(ratioOut) {
    }
    
    std::string message = "";
    bool isSucess = false;
    bool isChangeCard = false;
    int cardPos = 0;
    int resultCode = 0;
    float ratioOut;
    std::string croppedRect;
};

class PrimaryData {
public:
    PrimaryData(const std::string &imageName, const string &cardSide, const bool &isFront,
                int cardPos, float refWidth, float refHeight, int imgHeight,
                std::vector<string> rect)
    : imageName(imageName), cardSide(cardSide), isFront(isFront), cardPos(cardPos),
    refWidth(refWidth), refHeight(refHeight), imgHeight(imgHeight), rect(rect) {}
    
    std::string imageName = "";
    std::string cardSide = "";
    bool isFront = true;
    int cardPos = 0;
    float refWidth = 0;
    float refHeight = 0;
    int imgHeight = 0;
    std::vector<string> rect;
};



//int isMrzEnable = 0;
//int isPDFEnable = 0;
//int isOcrEnable = 0;
//
//inline std::string blurKey = "blur_percentage";
//inline std::string blurFaceKey = "face_blur_percentage";
//inline std::string glareMinKey = "glare_min_percentage";
//inline std::string glareMaxKey = "glare_max_percentage";
//inline std::string photocopyKey = "photocopy";
//inline std::string hologramDetectionKey = "hologram_detection";
//inline std::string dateValidation = "date_validation";

bool doBlurCheck(cv::Mat mat);

bool doBlurCheckFace(cv::Mat mat);

bool doGlareCheck(cv::Mat mat);

MinMaxLocResult multiScaleTemplateMatch(cv::Mat refMat, cv::Mat src, float d);

int getCroppedCard(cv::Mat &mat, cv::Mat &resultMat, cv::Rect rect);

bool doGrayScaleCheck(cv::Mat mat);

ImageOpenCv
checkCardInFrameOrNot(cv::Mat src, cv::Mat &resultMat, cv::Rect &finalCroppedRect);

ImageOpenCv getObject(string basicString, bool sucess, bool card, int pos, float out, int i);

//    map<int, Data_t>
std::string Mapping(cv::Mat &src,/* float *imageHeightWidth, */int **boxBounds, int elementsLength,
                    string *textArray, int isMrzEnable/*, nlohmann::json first*/);

void setPathtoSave(std::string path);

bool ComPareTwoImage(cv::Mat temp, cv::Mat src);

bool CheckAvaibiltyofPromorydata(cv::Mat pclone, cv::Mat tclone);

float checkSubImage(cv::Mat tclone, cv::Mat pclone);

bool doChangeTemplete = true;

void eraseSubString(std::string &mainStr, const std::string &toErase);

std::vector<std::string> splitString(std::string basic_string, const std::string string);

cv::CascadeClassifier face_cascade;

bool openCvFaceDetect(string string1, cv::Mat frame, cv::Mat &faceMat,
                      Recte sampleRect, cv::Rect &faceRect);

//int findHologram(void *hFaceHandle, BYTE *byGray, int w, int h, float &fConf) ;

string NullPointerError(int code = 0, std::string message = "Failed");

vector<cv::Mat> setAllTempletes(string *textArray, int i);

string createJsonResponse(int i, string message, nlohmann::json mapDataa);

string getReferenceHeight(int countryid, int cardid, /*nlohmann::json wholeresponce1, */int widthPixels, int isMrzEnable);

void setStoreValues(string key, string string1, bool isEncrypt);
std::string getSharedValue(std::string key, bool isDecrypt);
void setIntValues(std::string key, int i);
int getIntValue(std::string key);


int docrecog_scan_RecogEngine_loadDictionary(std::string path_file, NSString* path, string dairectorypath);
string imageToBase64(cv::Mat img);
int base64ToImage(string encodedString, cv::Mat &img);

//nlohmann::json saveJsonString(nlohmann::json licenseData_);

void Logger(string logMsg, bool isPrint = false);

string docrecog_scan_RecogEngine_loadData(int *jint1);



#endif
