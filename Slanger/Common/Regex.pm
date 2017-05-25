package Slanger::Common::Regex;
use strict;
use warnings;
use utf8;
our $re = {
  'zh' => qr{[\p{InCJKCompatibility}]|[\p{InCJKCompatibilityForms}]|[\p{InCJKCompatibilityIdeographs}]|[\p{InCJKCompatibilityIdeographsSupplement}]|[\p{InCJKRadicalsSupplement}]|[\p{InCJKUnifiedIdeographs}]|[\p{InCJKUnifiedIdeographsExtensionA}]|[\p{InCJKUnifiedIdeographsExtensionB}]},
  'en' => qr{[\p{InBasicLatin}-]},
  'ru' => qr{[\p{InCyrillic}-]},
};
1;