<?php

return [
    'target_php_version' => '8.3',
    'directory_list' => [
        'src/',
        'tests/',
        'vendor/',
    ],
    'exclude_analysis_directory_list' => [
        'vendor/',
    ],
    'plugins' => [
        'AlwaysReturnPlugin',
        'DuplicateArrayKeyPlugin',
        'PregRegexCheckerPlugin',
        'PrintfCheckerPlugin',
        'UnreachableCodePlugin',
        'InvokePHPNativeSyntaxCheckPlugin',
        'PHPUnitAssertionPlugin',
        'EmptyStatementListPlugin',
        'LoopVariableReusePlugin',
        'RedundantAssignmentPlugin',
        'PHPUnitNotDeadCodePlugin',
        'WhitespacePlugin',
        'PHPDocRedundantPlugin',
    ],
    'exclude_file_regex' => '#vendor/rector/rector/stubs-rector/.*#',
    'plugin_config' => [
        'php_native_syntax_check_max_processes' => 4,
    ],
    'suppress_issue_types' => [
    ],
];
