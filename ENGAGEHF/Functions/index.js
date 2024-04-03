//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

// Based on https://github.com/StanfordBDHG/PediatricAppleWatchStudy/pull/54

const {onCall} = require("firebase-functions/v2/https");
const {logger, https} = require("firebase-functions/v2");
const {FieldValue} = require("firebase-admin/firestore");
const admin = require("firebase-admin");
const {beforeUserCreated} = require("firebase-functions/v2/identity");

admin.initializeApp();


