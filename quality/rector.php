<?php

declare(strict_types=1);

use Rector\CodingStyle\Rector\Encapsed\EncapsedStringsToSprintfRector;
use Rector\Config\RectorConfig;
use Rector\Set\ValueObject\{LevelSetList, SetList};
use Rector\Strict\Rector\BooleanNot\BooleanInBooleanNotRuleFixerRector;

return static function (RectorConfig $rectorConfig): void {
    $rectorConfig->paths([
        __DIR__ . '/../src',
    ]);

    $rectorConfig->sets([
        LevelSetList::UP_TO_PHP_85,
        SetList::CODE_QUALITY,
        SetList::CODING_STYLE,
        SetList::DEAD_CODE,
        SetList::STRICT_BOOLEANS,
        SetList::GMAGICK_TO_IMAGICK,
        SetList::PRIVATIZATION,
        SetList::TYPE_DECLARATION,
        SetList::EARLY_RETURN,
        SetList::INSTANCEOF,
    ]);

    $rectorConfig->skip([
        EncapsedStringsToSprintfRector::class,
        BooleanInBooleanNotRuleFixerRector::class,
    ]);
};
