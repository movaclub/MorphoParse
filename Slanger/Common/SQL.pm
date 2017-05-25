package Slanger::Common::SQL;

use strict;
use warnings;
use utf8;

our ($sql);

$sql = {
  'zhten_zi'  => q[
										SELECT
											unizi.uni AS `sch`,
											unizi.uni_pin AS `strans`,
											ziEN.en AS `tword`,
											MATCH(unizi.uni) AGAINST(?)
                    FROM
											unizi,
											zh_zi_ts,
											ziEN
                    WHERE
											unizi.id = zh_zi_ts.zi_tr AND
											zh_zi_ts.id = ziEN.zi_id AND
											MATCH(unizi.uni) AGAINST(?) AND
											unizi.uni LIKE ?
                    ORDER BY LENGTH(ziEN.en) ASC
                    LIMIT 15
	],
  'zhsen_zi'  => q[
                SELECT
                        unizi.uni AS `sch`,
                        unizi.uni_pin AS `strans`,
                        ziEN.en AS `tword`,
                        MATCH(unizi.uni) AGAINST(?)
                FROM ziEN,unizi,zh_zi_ts
                WHERE
                        unizi.id = zh_zi_ts.zi_sp AND
                        zh_zi_ts.id = ziEN.zi_id AND
                        MATCH(unizi.uni) AGAINST(?) AND
                        unizi.uni LIKE ?
                ORDER BY LENGTH(ziEN.en) ASC
                LIMIT 15
    ],
  'zhten_ci' => q[
										SELECT
											zhCIto.ci_tr AS `sword`,
											zhCIto.ci_pin AS `strans`,
											ciEN.en AS `tword`,
											MATCH(zhCIto.ci_tr) AGAINST(?)
                    FROM
											zhCIto,
											ciEN
                    WHERE
											zhCIto.id = ciEN.ci_id AND
											MATCH(zhCIto.ci_tr) AGAINST(?) AND
											zhCIto.ci_tr LIKE ?
										ORDER BY LENGTH(ciEN.en) ASC
                    LIMIT 15
	],
  'zhsen_ci' => q[
                    SELECT
                            zhCIto.ci_sp AS `sword`,
                            zhCIto.ci_pin AS `strans`,
                            ciEN.en AS `tword`,
                            MATCH(zhCIto.ci_sp) AGAINST(?)
                    FROM
                            zhCIto,
                            ciEN
                    WHERE
                            zhCIto.id = ciEN.ci_id AND
                            MATCH(zhCIto.ci_sp) AGAINST(?) AND
                            zhCIto.ci_sp LIKE ?
                            ORDER BY LENGTH(ciEN.en) ASC
                    LIMIT 15
    ],
  'zhtru_zi'  => q[
                SELECT
                        unizi.uni AS `sch`,
                        unizi.uni_pin AS `strans`,
                        ziRU.ru AS `tword`,
                        MATCH(unizi.uni) AGAINST(?)
                FROM ziRU,unizi,zh_zi_ts
                WHERE
                        unizi.id = zh_zi_ts.zi_tr AND
                        zh_zi_ts.id = ziRU.zi_id AND
                        MATCH(unizi.uni) AGAINST(?) AND
                        unizi.uni LIKE ?
                ORDER BY LENGTH(ziRU.ru) ASC
                LIMIT 15
    ],
  'zhsru_zi'  => q[
                SELECT
                        unizi.uni AS `sch`,
                        unizi.uni_pin AS `strans`,
                        ziRU.ru AS `tword`,
                        MATCH(unizi.uni) AGAINST(?)
                FROM ziRU,unizi,zh_zi_ts
                WHERE
                        unizi.id = zh_zi_ts.zi_sp AND
                        zh_zi_ts.id = ziRU.zi_id AND
                        MATCH(unizi.uni) AGAINST(?) AND
                        unizi.uni LIKE ?
                ORDER BY LENGTH(ziRU.ru) ASC
                LIMIT 15
    ],
  'zhtru_ci' => q[
                SELECT
                        zhCIto.ci_tr AS `sword`,
                        zhCIto.ci_pin AS `strans`,
                        ciRU.ru AS `tword`,
                        MATCH(zhCIto.ci_tr) AGAINST(?)
                FROM
                        zhCIto,
                        ciRU
                WHERE
                        zhCIto.id = ciRU.ci_id AND
                        MATCH(zhCIto.ci_tr) AGAINST(?) AND
                        zhCIto.ci_tr LIKE ?
                        ORDER BY LENGTH(ciRU.ru) ASC
                LIMIT 15
    ],
  'zhsru_ci' => q[
                SELECT
                        zhCIto.ci_sp AS `sword`,
                        zhCIto.ci_pin AS `strans`,
                        ciRU.ru AS `tword`,
                        MATCH(zhCIto.ci_sp) AGAINST(?)
                FROM
                        zhCIto,
                        ciRU
                WHERE
                        zhCIto.id = ciRU.ci_id AND
                        MATCH(zhCIto.ci_sp) AGAINST(?) AND
                        zhCIto.ci_sp LIKE ?
                        ORDER BY LENGTH(ciRU.ru) ASC
                LIMIT 15
    ],
  'ruzht_ci' => q[
                SELECT
                        ciRU.ru AS `sword`,
                        zhCIto.ci_pin AS `ttrans`,
                        zhCIto.ci_tr AS `tword`,
                        MATCH(ciRU.ru) AGAINST(?)
                FROM
                        zhCIto,
                        ciRU
                WHERE
                        zhCIto.id = ciRU.ci_id AND
                        MATCH(ciRU.ru) AGAINST(?) AND
                        ciRU.ru LIKE ?
                        ORDER BY LENGTH(zhCIto.ci_tr) ASC
                LIMIT 15
    ],
  'ruzhs_ci' => q[
                SELECT
                        ciRU.ru AS `sword`,
                        zhCIto.ci_pin AS `ttrans`,
                        zhCIto.ci_sp AS `tword`,
                        MATCH(ciRU.ru) AGAINST(?)
                FROM
                        zhCIto,
                        ciRU
                WHERE
                        zhCIto.id = ciRU.ci_id AND
                        MATCH(ciRU.ru) AGAINST(?) AND
                        ciRU.ru LIKE ?
                        ORDER BY LENGTH(zhCIto.ci_sp) ASC
                LIMIT 15
    ],
  'enzht_ci' => q[
                SELECT
                        ciEN.en AS `sword`,
                        zhCIto.ci_pin AS `ttrans`,
                        ciEN.en_trans AS `strans`,
                        zhCIto.ci_tr AS `tword`,
                        MATCH(ciEN.en) AGAINST(?)
                FROM
                        zhCIto,
                        ciEN
                WHERE
                        zhCIto.id = ciEN.ci_id AND
                        MATCH(ciEN.en) AGAINST(?) AND
                        ciEN.en LIKE ?
                        ORDER BY LENGTH(zhCIto.ci_tr) ASC
                LIMIT 15
    ],
  'enzhs_ci' => q[
                SELECT
                        ciEN.en AS `sword`,
                        zhCIto.ci_pin AS `ttrans`,
                        ciEN.en_trans AS `strans`,
                        zhCIto.ci_sp AS `tword`,
                        MATCH(ciEN.en) AGAINST(?)
                FROM
                        zhCIto,
                        ciEN
                WHERE
                        zhCIto.id = ciEN.ci_id AND
                        MATCH(ciEN.en) AGAINST(?) AND
                        ciEN.en LIKE ?
                        ORDER BY LENGTH(zhCIto.ci_sp) ASC
                LIMIT 15
    ],
  'ruzhs_zi' => q[
                SELECT
                    ziRU.ru AS `sword`,
                    unizi.uni AS `tch`,
                    unizi.uni_pin AS `ttrans`,
                    MATCH(ziRU.ru) AGAINST(?)
                FROM ziRU,unizi,zh_zi_ts
                WHERE
                    unizi.id = zh_zi_ts.zi_sp AND
                    zh_zi_ts.id = ziRU.zi_id AND
                    MATCH(ziRU.ru) AGAINST(?) AND
                    ziRU.ru LIKE ?
                LIMIT 15
    ],
  'ruzht_zi' => q[
                SELECT
                    ziRU.ru AS `sword`,
                    unizi.uni AS `tch`,
                    unizi.uni_pin AS `ttrans`,
                    MATCH(ziRU.ru) AGAINST(?)
                FROM ziRU,unizi,zh_zi_ts
                WHERE
                    unizi.id = zh_zi_ts.zi_tr AND
                    zh_zi_ts.id = ziRU.zi_id AND
                    MATCH(ziRU.ru) AGAINST(?) AND
                    ziRU.ru LIKE ?
                LIMIT 15
    ],
  'enzhs_zi' => q[
                SELECT
                    ziEN.en AS `sword`,
                    ziEN.en_trans AS `strans`,
                    unizi.uni AS `tch`,
                    unizi.uni_pin AS `ttrans`,
                    MATCH(ziEN.en) AGAINST(?)
                FROM ziEN,unizi,zh_zi_ts
                WHERE
                    unizi.id = zh_zi_ts.zi_sp AND
                    zh_zi_ts.id = ziEN.zi_id AND
                    MATCH(ziEN.en) AGAINST(?) AND
                    ziEN.en LIKE ?
                LIMIT 15
    ],
  'enzht_zi' => q[
                SELECT
                    ziEN.en AS `sword`,
                    ziEN.en_trans AS `strans`,
                    unizi.uni AS `tch`,
                    unizi.uni_pin AS `ttrans`,
                    MATCH(ziEN.en) AGAINST(?)
                FROM ziEN,unizi,zh_zi_ts
                WHERE
                    unizi.id = zh_zi_ts.zi_tr AND
                    zh_zi_ts.id = ziEN.zi_id AND
                    MATCH(ziEN.en) AGAINST(?) AND
                    ziEN.en LIKE ?
                LIMIT 15
    ],
  'ruen' => q[
            SELECT
                 RUen.word AS `sword`,
                 ENru.word AS `tword`,
                 ENru.trans AS `ttrans`,
                 MATCH(RUen.word) AGAINST(?)
            FROM ENru, RUen
            WHERE
                 ENru.id = RUen.en_id AND
                 MATCH(RUen.word) AGAINST(?) AND
                 MATCH(RUen.word) AGAINST(?)
           ORDER BY LENGTH( ENru.word ) ASC
           LIMIT 15
    ],
  'enru' => q[
            SELECT
                ENru.word AS `sword`,
                ENru.trans AS `strans`,
                RUen.word AS `tword`,
                MATCH(ENru.word) AGAINST(?)
            FROM ENru, RUen
            WHERE
                ENru.id = RUen.en_id AND
                MATCH(ENru.word) AGAINST(?) AND
                ENru.word LIKE ?
            ORDER BY LENGTH( RUen.word ) ASC
            LIMIT 15
    ],
  'enwf' => q[
            SELECT
                en_word.word AS `word`,
                en_wform.form AS `form`,
                MATCH(en_wform.form) AGAINST(?)
            FROM en_wform,en_word
            WHERE
                en_wform.word_id = en_word.id AND
                MATCH(en_wform.form) AGAINST(?) AND
                en_wform.form LIKE ?
    ],
  'ruwf' => q[
            SELECT
                ru_word.word AS `word`,
                ru_wform.wform AS `form`,
                MATCH(ru_wform.wform) AGAINST(?)
            FROM ru_wform,ru_word
            WHERE
                ru_wform.root_id = ru_word.id AND
                MATCH(ru_wform.wform) AGAINST(?) AND
                ru_wform.wform LIKE ?
    ],
};

1;