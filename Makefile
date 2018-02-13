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
# Versao: 0.2
# Data: 13/02/2018
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
# ------------------------------------------------------------------------
# [2018-0213-1436] {v0.2} <Luciano Goncalez>
#
# - Adicionando funcionalidades de construção e instalação do bootloader.
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

BOOLOADER_SECTORS = 3



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



.PHONY: all clean distclean kernel kernelrelease bootloader boot bootrelease image\
	install_vbr install_stage2 install_boot install_kernel\
	_build _bootloader_build _imagedir



all: image


clean:
	rm -rf $(BUILD_DIR)/*

distclean: clean
	-rm *.map *.bin *.img
	-rmdir $(BUILD_DIR)
	-sudo umount $(MAIN_DIR)/imagedisk
	-rmdir $(MAIN_DIR)/imagedisk


_build:
	-mkdir $(BUILD_DIR)


# Kernel

kernel: kernel.bin

kernelrelease:
	@$(MAKE) -sf Makefile.kernel release


kernel.bin: $(BUILD_DIR)/kernel.bin
	cp $(BUILD_DIR)/kernel.bin .
	cp $(BUILD_DIR)/kernel.map .

$(BUILD_DIR)/kernel.bin: _build
	make clean
	cp $(MAIN_DIR)/Makefile.kernel $(BUILD_DIR)/Makefile
	@$(MAKE) -C $(BUILD_DIR)


# Bootloader

bootloader: vbr.bin	boot.bin

boot: bootloader

bootrelease:
	@$(MAKE) -sf Makefile.bootloader release


_bootloader_build: _build
	make clean
	cp $(MAIN_DIR)/Makefile.bootloader $(BUILD_DIR)/Makefile
	@$(MAKE) -C $(BUILD_DIR)


vbr.bin: $(BUILD_DIR)/stage1.bin
	cp $(BUILD_DIR)/stage1.bin vbr.bin

boot.bin: $(BUILD_DIR)/stage2.bin
	cp $(BUILD_DIR)/stage2.bin boot.bin
	cp $(BUILD_DIR)/stage2.map .


$(BUILD_DIR)/stage1.bin: _bootloader_build

$(BUILD_DIR)/stage2.bin: _bootloader_build


# Image

image: install_boot install_kernel


install_boot: install_vbr install_stage2


install_vbr: vbr.bin boot.img
	cp $(MAIN_DIR)/vbr.bin $(MAIN_DIR)/temp.img
	dd if=$(MAIN_DIR)/boot.img of=$(MAIN_DIR)/temp.img bs=1 skip=11 seek=11 count=51 conv=notrunc
	dd if=$(MAIN_DIR)/temp.img of=$(MAIN_DIR)/boot.img bs=512 count=$(BOOLOADER_SECTORS) conv=notrunc
	rm temp.img
	sync

install_stage2:	boot.bin boot.img _imagedir
	sudo cp $(MAIN_DIR)/boot.bin $(MAIN_DIR)/imagedisk
	sync

install_kernel: kernel.bin boot.img _imagedir
	sudo cp $(MAIN_DIR)/kernel.bin $(MAIN_DIR)/imagedisk
	sync


boot.img:
	dd if=/dev/zero of=$(MAIN_DIR)/boot.img bs=512 count=2880
	mkfs -t fat -R $(BOOLOADER_SECTORS) -n LOSBOOTDISK $(MAIN_DIR)/boot.img

_imagedir: imagedisk
	@echo "Conteudo de imagedisk:"
	@sudo ls -1 $(MAIN_DIR)/imagedisk
	-sudo umount $(MAIN_DIR)/imagedisk
	sudo mount $(MAIN_DIR)/boot.img $(MAIN_DIR)/imagedisk

imagedisk:
	mkdir $(MAIN_DIR)/imagedisk
