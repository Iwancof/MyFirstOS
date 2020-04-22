/*
kernel.ls
kotetuco 2008 - 2016
*/

/*入力オブジェクトファイル(将来的にMakefileで定義)*/

/*出力オブジェクトファイル(Makefileで定義)*/


/* ENTRY(init_os) *?

/*出力フォーマット*/
/* OUTPUT_FORMAT("binary") */

/* _GLOBAL_OFFSET_TABLE(0) */

/*セクション*/
SECTIONS{
	/*.hrbオブジェクトファイルのフォーマットに従い、ヘッダを定義*/
  	/*
	.head 0x0 :
	{
		LONG((ADDR(.bss) + SIZEOF(.bss) + 0xfff) & ~ 0xfff)
		BYTE(0x48) BYTE(0x61) BYTE(0x72) BYTE(0x69)
		LONG(0x0)
		LONG(ADDR(.data))
		LONG(SIZEOF(.data))
		LONG(LOADADDR(.data))
		LONG(0xe9000000)
		LONG(init_os - 0x20)
		LONG((ADDR(.bss) + SIZEOF(.bss) + 0xf) & ~ 0xf)
	}
	*/


	/*.textセクションのメモリ開始位置*/
	.text 0x200000 + 0x1000: 
	AT(0x1000) SUBALIGN(1)
	{
		*(.text*)
		/*.textセクション全部を含む*/
		*(.text.init_os)
	}

	/*.dataセクションのメモリ開始位置*/
	.data 0x200000 + LOADADDR(.text) + SIZEOF(.text):
	/*.data :*/

	/*.dataセクションのファイル上の開始位置*/
	AT(LOADADDR(.text) + SIZEOF(.text)) SUBALIGN(4)
	{
		*(.data*)
		*(.rodata*)	
	}

	/*.bssセクションのメモリ開始位置(.dataセクションの終端から)*/
	.bss 0x200000 + LOADADDR(.data) + SIZEOF(.data) :

	/*.bssセクションのファイル上の開始位置*/
	AT(LOADADDR(.data) + SIZEOF(.data)) SUBALIGN(4)
	{
		*(.bss*)
	}

	/* 上記以外のセクションは無視する */
	.else : {*(*)} 
}
