#!/bin/bash
TOOLPATH=/home/f/tools

MANUAL=0
STAGE=2

if [ "$STAGE" = 1 ]; then
  echo "Initial west setup, run the following"
  echo '  west init -l app && west update'
  CMD="/bin/bash" 
  WS="/workspaces/zmk"
elif [ "$STAGE" = 2 ]; then
  echo "just building"
  # echo "  west build -d build/fock/left -b nice_nano_v2 -- -DSHIELD=fock_left -DZMK_EXTRA_MODULES='/workspaces/zmk-modules;' && \\"
  # echo "  west build -d build/fock/right -b nice_nano_v2 -- -DSHIELD=fock_right -DZMK_EXTRA_MODULES='/workspaces/zmk-modules;'"
  # echo ""
  # echo "  west build -b nice_nano_v2 -- -DSHIELD=fock_left -DZMK_CONFIG='/workspaces/zmk-config;'"
  # echo "or later"
  # echo "  west build -d build/fock/left && west build -d build/fock/right"
  CMD="/bin/bash" 
  WS="/workspaces/zmk/app"
else
  echo "non defined stage $STAGE"
  return 0
fi

IMAGE="vsc-zmk-3eef4ac9867e69e0363ff2fb21dddfb474e72eb56e61fa36ad06ab278a5d3b42"
VOLUMES="-v $TOOLPATH/zmk:/workspaces/zmk \
    -v $TOOLPATH/fock-zmk:/workspaces/zmk-config \
    -v $TOOLPATH/fock-zmk-module:/workspaces/zmk-modules "

if [ $MANUAL = 1 ]; then
  docker run -it -w "$WS" $VOLUMES $IMAGE "$CMD"
else
  CMD="west build -d build/fock/left -b nice_nano_v2 -- -DSHIELD=fock_left -DZMK_EXTRA_MODULES='/workspaces/zmk-modules;'"
  CMD="$CMD && west build -d build/fock/right -b nice_nano_v2 -- -DSHIELD=fock_right -DZMK_EXTRA_MODULES='/workspaces/zmk-modules;'"
  docker run -it -w "$WS" $VOLUMES $IMAGE sh -c "$CMD" && {
    TIMESTAMP="$(date +%y%m%d-%H%M%S)" 
    OUTPATH=build/$TIMESTAMP
    echo "Saving in $OUTPATH"
    mkdir -p $OUTPATH
    cp ../zmk/app/build/fock/left/zephyr/zmk.uf2 $OUTPATH/left.uf2   
    cp ../zmk/app/build/fock/right/zephyr/zmk.uf2 $OUTPATH/right.uf2   
  } || echo "Docker failed, not saving"
fi

