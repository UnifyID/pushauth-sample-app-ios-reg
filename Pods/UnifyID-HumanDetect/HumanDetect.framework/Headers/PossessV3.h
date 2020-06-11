//
// Copyright © 2019 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.
// Created on 4/19/19.
//

#pragma once

typedef struct {
    double f_minimum;
    double f_maximum;
    double f_absolute_sum_of_changes;
    double f_mean;
    double f_variance;
    double f_finite_difference;
    double f_skew;
    double f_kurtosis;
    double f_sigma_volume;
} V3_Features;

extern long possessV3_ingest(double t, double x, double y, double z);
V3_Features possessV3_features(const double *mags, const double *tensors, int size);
extern void possessV3_reset(void);
extern void reset_chunks(void);


