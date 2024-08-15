#!/usr/bin/env bash
source dt_utils.sh



PVV="$("$FOL_VEN"/bin/python -c 'import sys; v0=sys.version_info[0]; v1=sys.version_info[1]; print(f"{v0}{v1}")')"
REPO_PIP=https://www.piwheels.org/simple



title dt_install_ddh_wheels
_pb "INSTALL DDH WHEELS"


source "$FOL_VEN"/bin/activate
_e $? "cannot activate virtualenv"


case $PVV in
    39|311)
        _pb "[ 40% ] DDH using wheels for version $PVV"
        ;;
    *)
        _pr "[ 40% ] DDH no wheels available for this python version"
        exit 1
esac


# -----------
# wheel numpy
# -----------
export AR=$(arch)
if [ "$AR" == "armv7l" ]; then
    _WHL=numpy-1.26.4-cp"$PVV"-cp"$PVV"-linux_$AR.whl
else
    _WHL=numpy-1.26.4-cp"$PVV"-cp"$PVV"-manylinux_2_17_$AR.manylinux2014_$AR.whl
fi
_pb "[ 41% ] DDH doing wheel $_WHL"
wget $REPO_PIP/numpy/"$_WHL" -P "$FOL_DDT_WHL"
_e $? "cannot wget wheel $_WHL"
pip install --no-cache-dir "$FOL_DDT_WHL"/"$_WHL"
_e $? "cannot pip install wheel $_WHL"
rm "$FOL_DDT_WHL"/"$_WHL"


# -------------
# wheel pandas
# -------------
if [ "$AR" == "armv7l" ]; then
    _WHL=pandas-2.2.2-cp"$PVV"-cp"$PVV"-linux_$AR.whl
else
    _WHL=pandas-2.2.2-cp"$PVV"-cp"$PVV"-manylinux_2_17_$AR.manylinux2014_$AR.whl
fi
_pb "[ 41% ] DDH doing wheel $_WHL"
wget $REPO_PIP/pandas/"$_WHL" -P "$FOL_DDT_WHL"
_e $? "cannot wget wheel $_WHL"
pip install --no-cache-dir "$FOL_DDT_WHL"/"$_WHL"
_e $? "cannot pip install wheel $_WHL"
rm "$FOL_DDT_WHL"/"$_WHL"



# ----------
# wheel h5py
# ----------
if [ "$AR" == "armv7l" ]; then
    _WHL=h5py-3.10.0-cp"$PVV"-cp"$PVV"-linux_$AR.whl
else
    _WHL=h5py-3.10.0-cp"$PVV"-cp"$PVV"-manylinux_2_17_$AR.manylinux2014_$AR.whl
fi
_pb "[ 41% ] DDH doing wheel $_WHL"
wget $REPO_PIP/h5py/"$_WHL" -P "$FOL_DDT_WHL"
_e $? "cannot wget wheel $_WHL"
pip install --no-cache-dir "$FOL_DDT_WHL"/"$_WHL"
_e $? "cannot pip install wheel $_WHL"
rm "$FOL_DDT_WHL"/"$_WHL"


# --------------
# wheel botocore
# --------------
_WHL=botocore-1.29.165-py3-none-any.whl
_pb "[ 41% ] DDH doing wheel $_WHL"
pip install --no-cache-dir "$FOL_DDT_WHL"/"$_WHL"



# -----------
# wheel dbus
# -----------
if [ "$AR" == "armv7l" ]; then
    _WHL=dbus_fast-2.22.1-cp"$PVV"-cp"$PVV"-manylinux_2_31_armv7l.whl
else
    _WHL=dbus_fast-2.22.1-cp"$PVV"-cp"$PVV"-manylinux_2_17_$AR.manylinux2014_$AR.whl
fi
_pb "[ 41% ] DDH doing wheel $_WHL"
wget $REPO_PIP/dbus-fast/"$_WHL" -P "$FOL_DDT_WHL"
_e $? "cannot wget wheel $_WHL"
pip install --no-cache-dir "$FOL_DDT_WHL"/"$_WHL"
_e $? "cannot pip install wheel $_WHL"
rm "$FOL_DDT_WHL"/"$_WHL"


_pb "[ 100% ] install_ddh_wheels done"
