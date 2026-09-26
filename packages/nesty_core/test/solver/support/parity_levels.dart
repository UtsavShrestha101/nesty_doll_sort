// Inputs of the solver parity suite (test/parity/solver_parity_test.dart):
// levels as spec §5.1 JSON consts, so the suite reads no files and runs on
// every platform. They are copies of test/fixtures/ (whose files stay the
// source of truth for the VM suites) plus a large, never-thawing board that
// exercises the visited table and the queue at scale.
library;

const Map<String, Map<String, Object?>> parityLevels = {
  '001_l1_tutorial': {
    'schemaVersion': 1,
    'id': '001_l1_tutorial',
    'maxSize': 3,
    'shelves': [
      [
        {
          'type': 'open',
          'nest': ['red3'],
        },
        {'type': 'open', 'nest': null},
        {
          'type': 'open',
          'nest': ['red2'],
        },
      ],
      [
        {'type': 'open', 'nest': null},
        {
          'type': 'open',
          'nest': ['red1'],
        },
        {'type': 'open', 'nest': null},
      ],
    ],
  },
  '003_spec_5_1_example': {
    'schemaVersion': 1,
    'id': 'L0042',
    'maxSize': 4,
    'shelves': [
      [
        {
          'type': 'open',
          'nest': ['red4', 'red3'],
        },
        {'type': 'open', 'nest': null},
        {
          'type': 'tower',
          'stack': [
            ['blue2'],
            ['green4'],
            ['red2', 'red1'],
          ],
        },
      ],
      [
        {
          'type': 'locked',
          'unlockColor': 'red',
          'nest': ['green3', 'green2', 'green1'],
        },
        {
          'type': 'open',
          'nest': ['blue4', 'blue3'],
          'ice': 2,
        },
        {
          'type': 'open',
          'nest': ['blue1'],
        },
      ],
    ],
  },
  '004_placement_first': {
    'schemaVersion': 1,
    'id': '004_placement_first',
    'maxSize': 3,
    'shelves': [
      [
        {
          'type': 'tower',
          'stack': [
            ['red2'],
            ['blue1'],
          ],
        },
        {
          'type': 'tower',
          'stack': [
            ['blue2'],
            ['red1'],
          ],
        },
        {
          'type': 'open',
          'nest': ['red3'],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['blue3'],
        },
        {'type': 'open', 'nest': null},
      ],
    ],
  },
  '007_lock_opens': {
    'schemaVersion': 1,
    'id': '007_lock_opens',
    'maxSize': 3,
    'shelves': [
      [
        {
          'type': 'locked',
          'unlockColor': 'red',
          'nest': ['blue3'],
        },
        {
          'type': 'open',
          'nest': ['red3'],
        },
        {
          'type': 'open',
          'nest': ['red2', 'red1'],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['blue2', 'blue1'],
        },
        {'type': 'open', 'nest': null},
      ],
    ],
  },
  '008_large_open_board': {
    'schemaVersion': 1,
    'id': '008_large_open_board',
    'maxSize': 5,
    'shelves': [
      [
        {
          'type': 'open',
          'nest': ['red5', 'red4'],
        },
        {
          'type': 'open',
          'nest': ['yellow1'],
        },
        {
          'type': 'open',
          'nest': ['green3', 'green2', 'green1'],
        },
        {
          'type': 'open',
          'nest': ['blue5'],
        },
        {
          'type': 'open',
          'nest': ['teal3', 'teal2'],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['orange2', 'orange1'],
        },
        {
          'type': 'open',
          'nest': ['teal5', 'teal4'],
        },
        {
          'type': 'open',
          'nest': ['red3'],
        },
        {
          'type': 'open',
          'nest': ['yellow5', 'yellow4', 'yellow3'],
        },
        {
          'type': 'open',
          'nest': ['green5'],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['blue1'],
        },
        {
          'type': 'open',
          'nest': ['orange5'],
        },
        {
          'type': 'open',
          'nest': ['green4'],
        },
        {
          'type': 'open',
          'nest': ['red2', 'red1'],
        },
        {
          'type': 'open',
          'nest': ['teal1'],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['yellow2'],
        },
        {
          'type': 'open',
          'nest': ['blue4', 'blue3', 'blue2'],
        },
        {'type': 'open', 'nest': null},
        {
          'type': 'open',
          'nest': ['orange4', 'orange3'],
        },
      ],
    ],
  },
  'u001_lock_deadlock': {
    'schemaVersion': 1,
    'id': 'u001_lock_deadlock',
    'maxSize': 3,
    'shelves': [
      [
        {
          'type': 'locked',
          'unlockColor': 'red',
          'nest': ['blue3', 'blue2'],
        },
        {
          'type': 'locked',
          'unlockColor': 'blue',
          'nest': ['red3', 'red2'],
        },
        {
          'type': 'open',
          'nest': ['red1'],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['blue1'],
        },
        {'type': 'open', 'nest': null},
      ],
    ],
  },
  'u003_no_space_dead_end': {
    'schemaVersion': 1,
    'id': 'u003_no_space_dead_end',
    'maxSize': 3,
    'shelves': [
      [
        {
          'type': 'tower',
          'stack': [
            ['green2', 'green1'],
            ['red3'],
            ['blue3'],
          ],
        },
        {
          'type': 'tower',
          'stack': [
            ['blue2', 'blue1'],
            ['red2', 'red1'],
            ['green3'],
          ],
        },
        {'type': 'open', 'nest': null},
      ],
    ],
  },
  // Seven colors in five depth-3 towers and eight open slots; green4 is
  // under ice that outlasts every set, so no search can win and a budgeted
  // one runs to its budget (benchmark/solver_benchmark.dart).
  'frozen_wide_towers': {
    'schemaVersion': 1,
    'id': 'frozen_wide_towers',
    'maxSize': 4,
    'shelves': [
      [
        {
          'type': 'tower',
          'stack': [
            ['red4'],
            ['blue2', 'blue1'],
            ['green3'],
          ],
        },
        {
          'type': 'tower',
          'stack': [
            ['yellow4', 'yellow3'],
            ['red2'],
            ['teal1'],
          ],
        },
        {
          'type': 'tower',
          'stack': [
            ['green2', 'green1'],
            ['teal4'],
            ['blue4'],
          ],
        },
        {
          'type': 'tower',
          'stack': [
            ['orange3', 'orange2'],
            ['purple4'],
            ['yellow2', 'yellow1'],
          ],
        },
        {
          'type': 'tower',
          'stack': [
            ['teal3', 'teal2'],
            ['orange1'],
            ['red3'],
          ],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['purple3', 'purple2'],
        },
        {
          'type': 'open',
          'nest': ['green4'],
          'ice': 9,
        },
        {
          'type': 'open',
          'nest': ['red1'],
        },
        {
          'type': 'open',
          'nest': ['blue3'],
        },
        {
          'type': 'open',
          'nest': ['orange4'],
        },
      ],
      [
        {
          'type': 'open',
          'nest': ['purple1'],
        },
        {'type': 'open', 'nest': null},
        {'type': 'open', 'nest': null},
      ],
    ],
  },
};
