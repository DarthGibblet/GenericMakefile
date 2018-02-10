CC=g++
CFLAGS=-I.
APP_NAME=app
BUILD_DIR=build

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

HEADER_FILES=$(call rwildcard,,*.h)
BODY_FILES=$(call rwildcard,,*.cpp)

SOURCE_FILES=${HEADER_FILES} ${BODY_FILES}
BODY_BASE_NAMES=$(basename ${BODY_FILES} .cpp)
INTERMEDIATE_BASE_NAMES=$(addprefix ${BUILD_DIR}/, ${BODY_BASE_NAMES})
DEPENDENCY_FILES=$(addsuffix .d, ${INTERMEDIATE_BASE_NAMES})
OBJECT_FILES=$(addsuffix .o, ${INTERMEDIATE_BASE_NAMES})

.PHONY: build run clean depends link

build: link

run: build
	@${BUILD_DIR}/${APP_NAME}

clean:
	@rm -rvf ${BUILD_DIR}

depends: ${DEPENDENCY_FILES}

-include ${DEPENDENCY_FILES}

${BUILD_DIR}/%.o: %.cpp ${BUILD_DIR}/%.d
	@mkdir -p "$(dir $@)"
	${CC} ${CFLAGS} -c -o $@ $<

link: ${BUILD_DIR}/${APP_NAME}
	
${BUILD_DIR}/${APP_NAME}: ${DEPENDENCY_FILES} ${OBJECT_FILES}
	${CC} ${CFLAGS} -o ${BUILD_DIR}/${APP_NAME} ${OBJECT_FILES}

${BUILD_DIR}/%.d : %.cpp
	@mkdir -p "$(dir $@)"
	${CC} -MM $< -MT '$${BUILD_DIR}/$(patsubst %.cpp,%.o,$<) $${BUILD_DIR}/$(patsubst %.cpp,%.d,$<)' -MF $@
