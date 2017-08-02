/*
 *
 *  Created on: May 17, 2017
 *      Author: Mario Lüder
 *
 */

#include <stdio.h>
#include <stdlib.h>


#include "Learner.cuh"
#include "Classifier.cuh"
#include "FeatureTypes.cuh"
#include "FeatureValues.cuh"
#include "Image.cuh"

// load image includes
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <cuda_profiler_api.h>

#include "utilities.cuh"
#include "defines.cuh"

/**
 * Host function that prepares data array and passes it to the CUDA kernel.
 */
int main(void)
{
   // Original
   // std::string strongClassifierStr = "[[[[[[[49,22,1]],[[49,22,-1]]],18,0,0.0332471,-90686,1],[[[[12,36,1],[12,36,-1]]],0,12,0.0991827,-9593,1]],[0.0343905,0.110103],2.20634],[[[[[[16,66,1],[16,66,-1]]],57,20,0.108966,29552,-1],[[[[14,16,1]],[[14,16,-1]]],72,64,0.160855,3968,-1],[[[[26,4,1]],[[26,4,-1]]],33,100,0.183328,1901,-1],[[[[29,36,1],[29,36,-1]]],33,8,0.1819,25689,-1],[[[[4,6,1],[4,6,-1]]],84,0,0.169853,44211,1]],[0.122292,0.191689,0.224481,0.222345,0.204606],5.09883],[[[[[[26, 29, 1]], [[26, 29, -1]]], 18, 32, 0.0191388, 34104, 1],[[[[26, 3, 1]], [[26, 3, -1]], [[26, 3, 1]]], 21, 52, 0.0207317, 8115, -1]], [0.0195122, 0.0211706], 6.79186]]";

   //std::string strongClassifierStr = "[[[[[[[49,22,1]],[[49,22,-1]]],18,0,0.0332471,-90686,1],[[[[12,36,1],[12,36,-1]]],0,12,0.0991827,-9593,1]],[0.0343905,0.110103],2.20634],[[[[[[16,66,1],[16,66,-1]]],57,20,0.108966,29552,-1],[[[[14,16,1]],[[14,16,-1]]],72,64,0.160855,3968,-1],[[[[26,4,1]],[[26,4,-1]]],33,100,0.183328,1901,-1],[[[[29,36,1],[29,36,-1]]],33,8,0.1819,25689,-1],[[[[4,6,1],[4,6,-1]]],84,0,0.169853,44211,1]],[0.122292,0.191689,0.224481,0.222345,0.204606],5.09883],[[[[[[26, 29, 1]], [[26, 29, -1]]], 18, 32, 0.0191388, 34104, 1],[[[[26, 3, 1]], [[26, 3, -1]], [[26, 3, 1]]], 21, 52, 0.0207317, 8115, -1]], [0.0195122, 0.0211706], 7.78186]]";
   /*
   [[[[[[[49,22,1]],[[49,22,-1]]],18,0,0.0332471,-90686,1],[[[[22,8,1],[22,8,-1]]],48,104,0.0922494,-38536,1],[[[[8,26,1],[8,26,-1]]],0,20,0.144086,-6474,1],[[[[10,22,1]],[[10,22,-1]],[[10,22,1]]],0,32,0.160434,18853,1],[[[[26,4,1]],[[26,4,-1]]],30,100,0.154933,1657,-1]],
   [0.0343905,0.101624,0.168342,0.191091,0.183338],
   3.35143],
   [[[[[[49,22,1]],[[49,22,-1]]],6,0,0.176727,-40517,1],[[[[12,66,1],[12,66,-1]]],66,24,0.187417,21526,-1],[[[[14,16,1]],[[14,16,-1]]],75,64,0.194728,3836,-1],[[[[12,36,1],[12,36,-1]]],0,56,0.23373,-8190,1],[[[[22,66,1],[22,66,-1]]],39,0,0.228247,21777,-1],[[[[49,6,1]],[[49,6,-1]]],9,0,0.228516,-7595,1],[[[[49,6,1]],[[49,6,-1]]],18,52,0.236501,-3840,1],[[[[26,12,1]],[[26,12,-1]]],0,64,0.225154,2591,-1],[[[[49,3,1]],[[49,3,-1]]],21,48,0.265981,-921,1],[[[[6,3,1]],[[6,3,-1]]],39,104,0.264232,57,-1],[[[[14,3,1]],[[14,3,-1]]],6,104,0.265039,-136,1],[[[[10,22,1]],[[10,22,-1]],[[10,22,1]]],78,36,0.252234,16527,1],[[[[2,6,1],[2,6,-1]]],69,100,0.242955,396,-1]],
   [0.214664,0.230644,0.241816,0.305022,0.295752,0.296203,0.309759,0.290579,0.362362,0.359124,0.360616,0.337317,0.320925],
   7.37621],
   [[[[[[49,4,1]],[[49,4,-1]],[[49,4,1]]],42,0,0.0261283,29220,1],[[[[12,26,1],[12,26,-1],[12,26,1]]],39,32,0.0710643,28378,-1],[[[[2,26,1],[2,26,-1]]],72,12,0.11069,52,-1],[[[[29,36,1],[29,36,-1]]],24,48,0.104579,1347,-1],[[[[8,36,1],[8,36,-1]]],24,20,0.0969391,1184,1]],
   [0.0268293,0.0765008,0.124468,0.116793,0.107345],
   8.33607]
   ]
   */


   /* faces
   std::string strongClassifierStr = std::string() +
         "[[[[[[[49,22,1]],[[49,22,-1]]],18,0,0.0332471,-90686,1],[[[[12,36,1],[12,36,-1]]],0,12,0.0991827,-9593,1],[[[[16,6,1],[16,6,-1]]],57,84,0.148353,2177,-1]]," +
         "[0.0343905,0.110103,0.174196]," +
         "1.74758]," +
         "[[[[[[8,12,1]],[[8,12,-1]]],84,64,0.0523191,-7807,1],[[[[14,16,1]],[[14,16,-1]]],33,12,0.0340082,-27205,1],[[[[22,36,1],[22,36,-1]]],45,12,0.114434,21409,-1],[[[[14,22,1]],[[14,22,-1]]],12,0,0.189615,-7194,1],[[[[26,4,1]],[[26,4,-1]]],30,100,0.165921,1563,-1],[[[[6,12,1]],[[6,12,-1]]],81,88,0.183366,66521,1]]," +
         "[0.0552076,0.0352054,0.129221,0.233982,0.198927,0.224539]," +
         "5.84288]," +
         "[[[[[[12,26,1],[12,26,-1],[12,26,1]]],36,76,0.0178653,22526,-1],[[[[2,10,1],[2,10,-1]]],3,20,0.0707651,-591,1],[[[[12,26,1],[12,26,-1]]],0,72,0.173719,-2579,1],[[[[49,16,1]],[[49,16,-1]]],27,0,0.175738,-24893,1],[[[[10,4,1]],[[10,4,-1]]],72,80,0.21342,181,-1],[[[[29,49,1],[29,49,-1]]],30,56,0.221047,23861,-1],[[[[6,8,1]],[[6,8,-1]],[[6,8,1]]],0,8,0.209865,4279,1],[[[[6,6,1],[6,6,-1]]],12,84,0.220425,-470,1],[[[[6,6,1]],[[6,6,-1]]],6,84,0.210801,-16,-1],[[[[49,6,1]],[[49,6,-1]]],15,96,0.222737,5228,-1],[[[[8,26,1],[8,26,-1]]],60,8,0.230551,914,-1]]," +
         "[0.0181903,0.0761542,0.210242,0.213206,0.271327,0.283774,0.265606,0.282749,0.267108,0.286566,0.299632]," +
         "10.5988]" +
         "]";
   */

   const std::string strongClassifierStr = std::string() +
         "[[[[[[[37,9,1]],[[37,9,-1]]],14,42,0.0722678,-11910,1],[[[[9,19,1],[9,19,-1]]],2,40,0.139302,2671,-1],[[[[6,15,1],[6,15,-1]]],46,38,0.221818,-1048,1],[[[[7,12,1],[7,12,-1]]],20,20,0.309595,-146,1],[[[[37,7,1]],[[37,7,-1]]],0,38,0.304273,7860,-1],[[[[4,7,1],[4,7,-1]]],22,50,0.313412,-56,-1],[[[[23,6,1]],[[23,6,-1]]],18,8,0.314589,-747,1]]," +
         "[0.0778973,0.161848,0.285046,0.448425,0.437345,0.456478,0.458979]," +
         "2.36498]," +
         "[[[[[[4,7,1],[4,7,-1]]],22,52,0.118089,129,1],[[[[11,9,1],[11,9,-1]]],42,40,0.114848,-5313,1],[[[[12,11,1]],[[12,11,-1]]],14,42,0.160176,-4664,1],[[[[6,12,1],[6,12,-1]]],6,40,0.255777,1660,-1],[[[[19,6,1]],[[19,6,-1]]],20,16,0.307482,1270,-1],[[[[5,14,1]],[[5,14,-1]]],46,24,0.313964,535,-1],[[[[3,19,1],[3,19,-1]]],24,44,0.337147,-43,-1],[[[[19,2,1]],[[19,2,-1]],[[19,2,1]]],24,42,0.30694,444,1],[[[[4,11,1]],[[4,11,-1]]],44,42,0.333322,-265,1],[[[[4,12,1],[4,12,-1]]],46,26,0.31331,445,-1],[[[[2,23,1],[2,23,-1]]],34,34,0.318459,-33,-1]]," +
         "[0.133901,0.129749,0.190726,0.343684,0.444005,0.45765,0.508629,0.442877,0.499974,0.456261,0.467262]," +
         "4.87584]," +
         "[[[[[[6,23,1],[6,23,-1]]],44,22,0.306532,-1803,1],[[[[11,7,1],[11,7,-1]]],0,42,0.209304,2405,-1],[[[[19,11,1]],[[19,11,-1]]],32,42,0.249326,-7439,1],[[[[4,19,1],[4,19,-1]]],48,38,0.303418,-522,1],[[[[29,9,1]],[[29,9,-1]]],22,34,0.328433,5565,-1],[[[[6,19,1],[6,19,-1]]],22,20,0.31785,-94,1],[[[[2,9,1],[2,9,-1]]],24,52,0.345599,-11,-1],[[[[6,12,1],[6,12,-1]]],46,22,0.333976,1032,-1],[[[[2,12,1],[2,12,-1]]],34,42,0.340836,27,1],[[[[37,7,1]],[[37,7,-1]]],12,40,0.323105,-11022,1],[[[[9,6,1],[9,6,-1]]],10,20,0.335412,466,-1],[[[[2,12,1],[2,12,-1]]],28,36,0.342236,-20,-1],[[[[9,9,1]],[[9,9,-1]]],38,2,0.344255,-701,1],[[[[9,15,1],[9,15,-1]]],46,40,0.367458,-673,1],[[[[37,9,1]],[[37,9,-1]],[[37,9,1]]],16,36,0.347429,56379,-1],[[[[4,5,1],[4,5,-1]]],36,48,0.344398,45,1],[[[[6,29,1],[6,29,-1]]],30,10,0.358535,356,-1]]," +
         "[0.442027,0.264709,0.332137,0.435582,0.489055,0.465953,0.528115,0.501447,0.517074,0.477334,0.504692,0.520303,0.524982,0.580923,0.5324,0.525316,0.558932]," +
         "5.17667]," +
         "[[[[[[15,3,1]],[[15,3,-1]]],32,14,0.357625,-415,1],[[[[11,9,1],[11,9,-1]]],42,40,0.22983,-2473,1],[[[[7,7,1]],[[7,7,-1]]],12,44,0.25555,-1530,1],[[[[11,15,1],[11,15,-1]]],0,42,0.304966,1908,-1],[[[[23,4,1]],[[23,4,-1]]],22,14,0.298669,1395,-1],[[[[7,4,1],[7,4,-1]]],46,58,0.363699,-127,-1],[[[[46,3,1]],[[46,3,-1]]],8,24,0.341516,-701,1],[[[[9,15,1],[9,15,-1]]],8,30,0.358199,1294,-1],[[[[46,11,1]],[[46,11,-1]]],6,0,0.376073,-2108,1],[[[[3,12,1],[3,12,-1]]],24,22,0.372491,-17,1],[[[[15,4,1]],[[15,4,-1]]],28,42,0.364288,1270,-1],[[[[2,19,1],[2,19,-1]]],36,42,0.335782,-41,-1],[[[[15,7,1]],[[15,7,-1]],[[15,7,1]]],24,24,0.363369,3086,1],[[[[2,12,1],[2,12,-1]]],36,52,0.353335,13,1],[[[[6,3,1]],[[6,3,-1]]],46,38,0.375587,53,-1],[[[[3,4,1],[3,4,-1]]],12,22,0.384322,63,-1],[[[[7,4,1],[7,4,-1]]],2,60,0.373282,122,1],[[[[29,3,1]],[[29,3,-1]]],14,44,0.362953,-1968,1],[[[[4,6,1],[4,6,-1]]],0,50,0.351666,-28,-1],[[[[29,3,1]],[[29,3,-1]]],18,12,0.377998,-875,1],[[[[4,15,1],[4,15,-1]]],30,32,0.356224,-159,-1],[[[[7,12,1],[7,12,-1]]],6,22,0.374151,-1260,1]]," +
         "[0.556724,0.298414,0.343273,0.438778,0.425859,0.571584,0.518639,0.558116,0.602751,0.593603,0.57304,0.505529,0.570768,0.546396,0.601504,0.624225,0.595614,0.569744,0.542414,0.607711,0.553336,0.597831]," +
         "5.82418]," +
         "[[[[[[6,23,1]],[[6,23,-1]]],28,10,0.362304,-312,-1],[[[[4,12,1],[4,12,-1]]],48,40,0.273207,-1134,1],[[[[46,7,1]],[[46,7,-1]]],10,44,0.300423,-12809,1],[[[[4,9,1],[4,9,-1]]],8,40,0.329965,522,-1],[[[[37,6,1]],[[37,6,-1]]],8,16,0.349167,1951,-1],[[[[7,6,1]],[[7,6,-1]]],30,22,0.357,-282,1],[[[[2,9,1],[2,9,-1]]],24,36,0.361501,16,1],[[[[29,4,1]],[[29,4,-1]]],16,42,0.356843,-3483,1],[[[[6,12,1],[6,12,-1]]],22,44,0.350834,-351,-1],[[[[19,7,1]],[[19,7,-1]]],16,38,0.369914,6281,-1],[[[[6,15,1],[6,15,-1]]],26,38,0.348115,351,1],[[[[6,18,1]],[[6,18,-1]]],0,2,0.379527,-2670,1],[[[[7,18,1]],[[7,18,-1]]],14,14,0.363183,1646,-1],[[[[6,5,1],[6,5,-1]]],20,20,0.375229,-46,1],[[[[29,3,1]],[[29,3,-1]]],16,46,0.388475,933,-1],[[[[11,5,1],[11,5,-1]]],22,42,0.34913,-427,-1],[[[[19,3,1]],[[19,3,-1]]],20,46,0.3745,-1345,1],[[[[2,15,1],[2,15,-1]]],40,48,0.373118,22,1],[[[[23,2,1]],[[23,2,-1]]],20,44,0.387315,-570,1],[[[[2,6,1],[2,6,-1]]],0,48,0.370151,-6,-1],[[[[4,12,1],[4,12,-1]]],32,20,0.394314,62,-1],[[[[6,9,1],[6,9,-1]]],42,18,0.389872,573,-1],[[[[2,9,1],[2,9,-1]]],26,44,0.384178,23,1],[[[[4,5,1],[4,5,-1]]],44,20,0.376192,-216,1],[[[[2,6,1],[2,6,-1]]],36,48,0.393743,10,1],[[[[46,9,1]],[[46,9,-1]],[[46,9,1]]],6,36,0.378022,78834,-1],[[[[7,15,1],[7,15,-1]]],6,42,0.369337,313,-1],[[[[19,2,1]],[[19,2,-1]]],26,16,0.389239,-263,1]]," +
         "[0.568144,0.375907,0.429435,0.492459,0.536493,0.555209,0.566174,0.554831,0.540439,0.587085,0.534013,0.611674,0.57031,0.600586,0.635257,0.536406,0.598722,0.595196,0.63216,0.587682,0.65102,0.639001,0.623846,0.603056,0.649465,0.607774,0.585633,0.637303]," +
         "6.70576]," +
         "[[[[[[2,12,1],[2,12,-1]]],24,50,0.118233,-54,-1],[[[[7,5,1],[7,5,-1]]],46,44,0.269884,-1924,1],[[[[6,7,1]],[[6,7,-1]]],44,44,0.329405,-1264,1],[[[[4,15,1],[4,15,-1]]],8,28,0.337763,1215,-1],[[[[4,7,1]],[[4,7,-1]]],14,34,0.350873,132,-1],[[[[5,3,1]],[[5,3,-1]]],36,16,0.372926,118,-1],[[[[9,37,1],[9,37,-1]]],20,20,0.356839,600,1],[[[[5,7,1]],[[5,7,-1]]],18,38,0.36587,-811,1],[[[[7,3,1]],[[7,3,-1]]],8,42,0.369258,12,-1],[[[[4,4,1],[4,4,-1]]],48,40,0.364553,-120,1],[[[[18,4,1],[18,4,-1]]],24,60,0.380133,-445,-1],[[[[7,4,1],[7,4,-1]]],44,26,0.349521,680,-1],[[[[2,37,1],[2,37,-1]]],34,14,0.363969,-47,-1],[[[[37,2,1]],[[37,2,-1]],[[37,2,1]]],12,42,0.373492,926,1],[[[[6,4,1],[6,4,-1]]],26,44,0.376832,-121,-1],[[[[5,18,1]],[[5,18,-1]]],52,6,0.372366,-1122,1],[[[[5,3,1]],[[5,3,-1]]],14,28,0.384005,17,-1],[[[[6,6,1]],[[6,6,-1]]],18,12,0.385093,335,-1],[[[[7,19,1],[7,19,-1]]],6,42,0.382152,889,-1],[[[[29,9,1]],[[29,9,-1]]],2,4,0.377142,-4229,1],[[[[2,12,1],[2,12,-1]]],24,52,0.38441,25,1],[[[[9,4,1]],[[9,4,-1]]],32,44,0.366915,348,-1],[[[[7,7,1]],[[7,7,-1]]],26,42,0.371861,-271,1],[[[[2,9,1],[2,9,-1]]],38,36,0.397504,-7,-1],[[[[46,6,1]],[[46,6,-1]]],2,42,0.382561,4791,-1],[[[[2,23,1],[2,23,-1]]],30,32,0.372825,56,1],[[[[9,15,1],[9,15,-1]]],4,24,0.394819,-1738,1],[[[[2,4,1],[2,4,-1]]],34,38,0.384465,8,1],[[[[3,6,1],[3,6,-1]]],10,38,0.397311,159,-1],[[[[9,23,1],[9,23,-1]]],26,32,0.394612,-507,-1],[[[[19,2,1]],[[19,2,-1]]],20,18,0.395946,414,-1],[[[[2,23,1],[2,23,-1]]],58,40,0.375594,42,1],[[[[15,3,1]],[[15,3,-1]]],0,28,0.391987,66,-1],[[[[2,29,1],[2,29,-1]]],58,34,0.405225,-76,-1],[[[[3,5,1],[3,5,-1]]],42,20,0.375862,-225,1],[[[[3,15,1],[3,15,-1]]],32,42,0.39361,108,1]]," +
         "[0.134087,0.369645,0.491214,0.510033,0.54053,0.594709,0.554821,0.576964,0.585435,0.573697,0.61325,0.537328,0.57225,0.596148,0.604704,0.593286,0.62339,0.626263,0.618521,0.605502,0.624457,0.579566,0.592005,0.659763,0.619592,0.594452,0.652398,0.624603,0.659231,0.651833,0.655481,0.601521,0.644703,0.681308,0.602211,0.649105]," +
         "9.8075]," +
         "[[[[[[6,7,1],[6,7,-1]]],44,56,0.136025,-320,-1],[[[[4,23,1],[4,23,-1]]],48,38,0.190645,-328,1],[[[[7,19,1],[7,19,-1]]],4,40,0.311019,694,-1],[[[[6,7,1]],[[6,7,-1]]],26,32,0.318329,536,-1],[[[[4,6,1]],[[4,6,-1]]],14,38,0.343725,67,-1],[[[[3,5,1],[3,5,-1]]],30,36,0.345505,29,1],[[[[9,3,1]],[[9,3,-1]]],30,12,0.327865,-235,1],[[[[9,4,1]],[[9,4,-1]]],26,20,0.349474,102,-1],[[[[4,23,1],[4,23,-1]]],24,18,0.36096,-118,1],[[[[5,9,1]],[[5,9,-1]]],32,38,0.365004,-721,1],[[[[9,2,1]],[[9,2,-1]]],2,22,0.368992,6,-1],[[[[7,5,1],[7,5,-1]]],10,22,0.356832,138,-1],[[[[2,6,1],[2,6,-1]]],26,24,0.374459,-49,-1],[[[[4,15,1],[4,15,-1]]],48,28,0.327256,451,-1],[[[[3,6,1],[3,6,-1]]],22,34,0.355475,40,1],[[[[3,9,1],[3,9,-1]]],44,42,0.371024,75,-1],[[[[14,5,1],[14,5,-1]]],20,28,0.360171,-115,-1],[[[[14,4,1],[14,4,-1]]],34,48,0.380502,-241,1],[[[[6,4,1],[6,4,-1]]],42,24,0.370695,478,-1],[[[[2,5,1],[2,5,-1]]],28,50,0.344563,17,1],[[[[4,11,1]],[[4,11,-1]]],60,24,0.375718,-707,1],[[[[5,2,1]],[[5,2,-1]]],10,40,0.367993,6,-1],[[[[2,7,1],[2,7,-1]]],28,36,0.365275,21,1],[[[[3,12,1],[3,12,-1]]],46,22,0.368608,-316,1],[[[[5,7,1]],[[5,7,-1]]],34,48,0.380288,-155,1],[[[[5,7,1]],[[5,7,-1]]],18,38,0.378386,-619,1],[[[[23,7,1],[23,7,-1]]],12,6,0.379553,-2028,-1],[[[[7,3,1]],[[7,3,-1]]],26,42,0.37381,95,-1],[[[[7,3,1]],[[7,3,-1]],[[7,3,1]]],6,0,0.377489,1876,1],[[[[4,11,1]],[[4,11,-1]]],38,10,0.380719,-74,-1],[[[[15,4,1]],[[15,4,-1]]],6,44,0.37648,523,-1],[[[[2,4,1],[2,4,-1]]],26,48,0.362516,-7,-1]]," +
         "[0.157441,0.235552,0.451418,0.466984,0.523751,0.527896,0.487796,0.537219,0.564847,0.574814,0.584766,0.554804,0.598617,0.486449,0.55153,0.589886,0.562917,0.614211,0.589055,0.5257,0.601841,0.582262,0.575486,0.583803,0.613654,0.608715,0.611741,0.59696,0.606397,0.614775,0.603798,0.568666]," +
         "10.4996]," +
         "[[[[[[9,6,1],[9,6,-1]]],24,16,0.0973628,-1013,-1],[[[[2,4,1],[2,4,-1]]],10,56,0.0969183,51,1],[[[[7,23,1],[7,23,-1]]],46,40,0.238902,-1679,1],[[[[15,2,1]],[[15,2,-1]]],0,50,0.279055,-24,1],[[[[6,37,1],[6,37,-1]]],20,20,0.280371,-298,1],[[[[7,7,1]],[[7,7,-1]]],32,32,0.301474,164,-1],[[[[5,7,1]],[[5,7,-1]],[[5,7,1]]],28,18,0.294877,4094,1],[[[[19,4,1]],[[19,4,-1]]],44,26,0.295817,285,-1],[[[[4,9,1],[4,9,-1],[4,9,1]]],8,10,0.303268,2398,-1],[[[[6,12,1],[6,12,-1]]],22,16,0.30914,-121,1],[[[[23,4,1]],[[23,4,-1]]],16,10,0.321248,-372,1],[[[[3,4,1],[3,4,-1]]],32,32,0.289848,50,1],[[[[9,5,1],[9,5,-1]]],0,42,0.317217,1471,-1],[[[[7,7,1],[7,7,-1]]],2,22,0.325678,-36,1],[[[[2,7,1],[2,7,-1]]],26,34,0.304275,16,1],[[[[14,19,1],[14,19,-1]]],0,44,0.315893,1255,-1],[[[[6,7,1]],[[6,7,-1]]],50,20,0.306878,-303,1]]," +
         "[0.107865,0.10732,0.313891,0.387069,0.389605,0.431586,0.418191,0.420085,0.435273,0.447472,0.473293,0.408149,0.464593,0.482972,0.43735,0.461761,0.442747]," +
         "9.44836]," +
         "[[[[[[3,4,1],[3,4,-1]]],20,18,0.0780923,-225,-1],[[[[2,5,1],[2,5,-1],[2,5,1]]],26,32,0.0286999,17,-1],[[[[4,19,1],[4,19,-1]]],24,18,0.148638,-129,1],[[[[2,15,1],[2,15,-1]]],24,38,0.177829,-72,-1],[[[[14,15,1],[14,15,-1]]],0,44,0.177649,910,-1],[[[[6,2,1]],[[6,2,-1]]],42,28,0.177444,9,-1],[[[[3,7,1],[3,7,-1]]],40,52,0.197775,78,1]]," +
         "[0.0847072,0.0295479,0.174589,0.216293,0.216026,0.215722,0.246533]," +
         "8.92168]," +
         "[[[[[[6,18,1]],[[6,18,-1]]],14,12,0.0127814,-2710,-1],[[[[23,11,1]],[[23,11,-1]],[[23,11,1]]],8,0,0.000169941,57111,1],[[[[11,12,1],[11,12,-1]]],0,44,0.00829618,246,-1]]," +
         "[0.0129469,0.00016997,0.00836558]," +
         "13.0268]" +
         "]";



   // test face
   //const std::string imageFileName = "/mnt/project-disk/src/ObjectRecognition/data/facesTraining/tutorial-haartraining/data/CMU-MIT_Face_Test_Set/newtest/ew-courtney-david.png";

   // test car
   const std::string imageFileName = "/mnt/project-disk/src/ObjectRecognition/data/cars/TheKITTIVision/testing/image_2/000006.png";

   deviceSetup();

   cudaEvent_t start, stop;
   cudaEventCreate(&start);
   cudaEventCreate(&stop);

   Image image;
   Image::fromFile(imageFileName, image);

   std::vector<Classifier::Stage> strongClassifier;
   FeatureTypes featureTypes;
   Classifier::fromResult(strongClassifierStr, strongClassifier, featureTypes);

   std::vector<Classifier::ClassificationResult> results;

   // define all scales for a strong classifier
   std::vector<double> classifierScales;

   // classifierScales.push_back(0.5);
   // classifierScales.push_back(0.75);
   classifierScales.push_back(1.0);
   // classifierScales.push_back(1.1);
   // classifierScales.push_back(1.2);
   // classifierScales.push_back(1.4);
   // classifierScales.push_back(1.6);

   // use the defined scales to detect objects
   for (std::vector<double>::const_iterator classifierScalesIter = classifierScales.begin();
         classifierScalesIter != classifierScales.end();
         ++classifierScalesIter)
   {
      std::vector<Classifier::Stage> scaledStrongClassifier;
      FeatureTypes scaledFeatureTypes;
      Classifier::scaleStrongClassifier(*classifierScalesIter, strongClassifier, featureTypes, scaledStrongClassifier, scaledFeatureTypes);
      scaledFeatureTypes.generateClassifier(1.0, image.getWidth(), image.getHeight(), true);
      Classifier::detectStrongClassifier(scaledStrongClassifier, scaledFeatureTypes, image.getGpuIntegralImage(), results);

   }

   image.displayClassificationResult(results);

	return 0;
}
