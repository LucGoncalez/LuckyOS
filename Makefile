#===========================================================================
# Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
# --------------------------------------------------------------------------
# Copyright (C) 2013 - Luciano L. Goncalez
# --------------------------------------------------------------------------
# a.k.a.: Master Lucky
# eMail : master.lucky.br@gmail.com
# Home  : http://lucky-labs.blogspot.com.br
# ==========================================================================
# Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
# sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
# Software Foundation; na versao 2 da Licenca.
#
# Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
# GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
# ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
# Geral GNU para obter mais detalhes.
#
# Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
# este programa; se nao, escreva para a Free Software Foundation, Inc., 59
# Temple Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do
# GNU e obtenha sua licenca: http://www.gnu.org/
# ==========================================================================
# Makefile (Geral)
# --------------------------------------------------------------------------
#   Este é o arquivo de makefile, ele é responsavel pelas construção do
# sistema.
# --------------------------------------------------------------------------
# Versao: 0.1
# Data: 24/01/2018
# --------------------------------------------------------------------------
# Uso:
# > make
# ------------------------------------------------------------------------
# Executar: Arquivo de configuracao.
#============================================================================
# Historico de versões
# ------------------------------------------------------------------------
# [2018-0124-2151] {v0.1} <Luciano Goncalez>
#
# - Implementação inicial.
#============================================================================


## Configurações gerais ##
ASSEMBLER_NAME = nasm
COMPILER_NAME = ppc386
LINKER_NAME = ld

COMPILER_VERSIONR = 2.4.4

# Tools #

ASSEMBLER = $(shell which $(ASSEMBLER_NAME))
COMPILER = $(shell which $(COMPILER_NAME))
LINKER = $(shell which $(LINKER_NAME))

export ASSEMBLER COMPILER LINKER


## Checagens ##

# Assembler
ifeq ("$(ASSEMBLER)", "")
assembler_error:
	@echo >&2
	@echo >&2 "Não foi possível detectar o assembler: $(ASSEMBLER_NAME)"
	@echo >&2
	@exit 1
endif

# Compiler
ifeq ("$(COMPILER)", "")
compiler_error:
	@echo >&2
	@echo >&2 "Não foi possível detectar o compilador: $(COMPILER_NAME)"
	@echo >&2
	@exit 1
endif

COMPILER_VERSION = $(shell $(COMPILER) -iV)

ifneq ("$(COMPILER_VERSION)", "$(COMPILER_VERSIONR)")
compiler_version_error:
	@echo >&2
	@echo >&2 "Versão incorreta do compilador:"
	@echo >&2 "Encontrada: $(COMPILER_VERSION)"
	@echo >&2 "Requerida: $(COMPILER_VERSIONR)"
	@echo >&2
	@exit 1
endif

# Linker
ifeq ("$(LINKER)", "")
linker_error:
	@echo >&2
	@echo >&2 "Não foi possível detectar o linker: $(LINKER_NAME)"
	@echo >&2
	@exit 1
endif

MAIN_DIR := $(CURDIR)

CONFIG_DIR := $(MAIN_DIR)/config
BUILD_DIR := $(MAIN_DIR)/build

export MAIN_DIR CONFIG_DIR BUILD_DIR


.PHONY: all clean distclean kernel kernelrelease

all: kernel

clean:
	rm -rf $(BUILD_DIR)/*

distclean: clean
	-rm *.map *.bin
	-rmdir $(BUILD_DIR)


kernel: kernel.bin

kernelrelease:
	@$(MAKE) -sf Makefile.kernel release


build:
	mkdir $(BUILD_DIR)


kernel.bin: $(BUILD_DIR)/kernel.bin
	cp $(BUILD_DIR)/kernel.bin .
	cp $(BUILD_DIR)/kernel.map .

$(BUILD_DIR)/kernel.bin: clean build
	cp $(MAIN_DIR)/Makefile.kernel $(BUILD_DIR)/Makefile
	@$(MAKE) -C $(BUILD_DIR)
