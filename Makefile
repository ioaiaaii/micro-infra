# +++ Overrides to Repo Operator
override OPERATOR_PATH := repo-operator

# +++ Include make files from Repo Operator
include ${OPERATOR_PATH}/makefiles/base.mk

# +++ Local configuration starts, hit `make help` to fetch all available targets