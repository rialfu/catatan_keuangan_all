import { User } from "src/model/user.entity";
import { Column, CreateDateColumn, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn, UpdateDateColumn } from "typeorm";

@Entity()
export class CodeReset {
    @PrimaryGeneratedColumn('increment', {type:'bigint',unsigned:true}) //it is used to generate primary id, when new data inserted.
    id: number;

    @Column({length:8}) // It is used to mark a specific class property as a table column
    code: string;

    @Column({'type':'datetime'})
    expired_date: Date;
    
   
    @OneToOne(()=>User, user=>user.code_reset)
    // @JoinColumn({name:'userId', referencedColumnName:'id'})
    user: User;
    @Column({default:true})
    valid: boolean;
    
    @CreateDateColumn()
    createdon: Date;
    
    @UpdateDateColumn()
    updatedon: Date;

    
}